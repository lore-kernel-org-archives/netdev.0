From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [net-next PATCH 3/4] net: sched: cls_u32 add bit to specify
 software only rules
Date: Wed, 24 Feb 2016 10:29:07 +0100
Message-ID: <20160224102907.05aa8e42@griffin>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
	<20160223190321.5970.58924.stgit@john-Precision-Tower-5810>
	<20160224080440.GA26500@office.Home>
	<20160224084057.GC2151@nanopsycho.orion>
	<56CD701B.8070308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, "Amir Vadai\"" <amir@vadai.me>,
	daniel@iogearbox.net, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com, davem@davemloft.net, jhs@mojatatu.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33753 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751871AbcBXJ3M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 04:29:12 -0500
In-Reply-To: <56CD701B.8070308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Feb 2016 00:55:55 -0800, John Fastabend wrote:
> The flags however likely stays with with TCA_U32_FLAGS until there is
> some better way to group common attributes in 'tc' framework.

That's pretty bad, as this is uAPI and will need to be supported
forever. And having a different attribute in every filter won't ease
things for user space tools. I'd say we need the "better way" to be
added before this patchset.

 Jiri
