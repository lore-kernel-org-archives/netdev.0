From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3] tc: introduce OpenFlow classifier
Date: Sun, 12 Apr 2015 09:53:51 +0200
Message-ID: <20150412075351.GA2112@nanopsycho.orion>
References: <1428584287-8197-1-git-send-email-jiri@resnulli.us>
 <20150409.173423.2258417584616634411.davem@davemloft.net>
 <20150410091203.GA2021@nanopsycho.orion>
 <20150410.082359.964457460073432676.davem@davemloft.net>
 <20150410124517.GC2021@nanopsycho.orion>
 <20150411161223.GA802@Alexeis-MBP.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, jesse@nicira.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33847 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbbDLHxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 03:53:55 -0400
Received: by widjs5 with SMTP id js5so42930760wid.1
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 00:53:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150411161223.GA802@Alexeis-MBP.westell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Apr 11, 2015 at 06:12:25PM CEST, alexei.starovoitov@gmail.com wrote:
>On Fri, Apr 10, 2015 at 02:45:17PM +0200, Jiri Pirko wrote:
>> Okay. That was misunderstanding. I was thinking about using existing
>> flow_dissect. There are couple things which I'm scared of:
>> - there are eventually many fields to be added to dissection function and to
>>   the structure as well. Not sure how acceptable that would be for
>>   performance reasons when flow_dissect is used by different users...
>
>I share the same concern. I think flow_dissect is too performance
>critical to reuse by expanding 'struct flow_keys'.
>I think it would be better to generalize ovs's key_extract() into
>common piece of code that TC classifier and ovs datapath can use.
>It uses kernel internal 'struct sw_flow_key' which we can tweak to
>accommodate more users. It's already gigantic at 392 bytes, so
>split and a bit of diet would help too.

Yep, those are few next topics on my agenda.

Thanks

Jiri
