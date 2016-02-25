From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 3/4] net: sched: cls_u32 add bit to specify software
 only rules
Date: Wed, 24 Feb 2016 20:09:46 -0800
Message-ID: <56CE7E8A.3040202@gmail.com>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>	<20160223190321.5970.58924.stgit@john-Precision-Tower-5810>	<20160224080440.GA26500@office.Home>	<20160224084057.GC2151@nanopsycho.orion>	<56CD701B.8070308@gmail.com> <20160224102907.05aa8e42@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, "Amir Vadai\"" <amir@vadai.me>,
	daniel@iogearbox.net, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com, davem@davemloft.net, jhs@mojatatu.com
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35999 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753007AbcBYEKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 23:10:00 -0500
Received: by mail-pf0-f178.google.com with SMTP id e127so25216820pfe.3
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 20:09:59 -0800 (PST)
In-Reply-To: <20160224102907.05aa8e42@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-24 01:29 AM, Jiri Benc wrote:
> On Wed, 24 Feb 2016 00:55:55 -0800, John Fastabend wrote:
>> The flags however likely stays with with TCA_U32_FLAGS until there is
>> some better way to group common attributes in 'tc' framework.
> 
> That's pretty bad, as this is uAPI and will need to be supported
> forever. And having a different attribute in every filter won't ease
> things for user space tools. I'd say we need the "better way" to be
> added before this patchset.
> 
>  Jiri
> 

The 'tc' semantics seem to support this "pretty bad" API design
with many of the fields already duplicated. I suppose we could
put the flags at the same level as the TCA_* attributes but this
also doesn't seem right to me as it isn't actually handled until
we get into the TCA_#CLASSIFIER#_* set of attributes.

.John
