From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [NET_SCHED 00/04]: External SFQ classifiers/flow classifier
Date: Fri, 04 Apr 2008 18:01:18 +0100
Message-ID: <47F65EDE.3010507@andyfurniss.entadsl.com>
References: <20080131175758.25151.20370.sendpatchset@localhost.localdomain> <47A4FB81.80700@fatooh.org> <47A74FEE.6080103@trash.net> <47EED247.50801@andyfurniss.entadsl.com> <47F22CF5.4080806@trash.net> <47F28758.1010401@andyfurniss.entadsl.com> <47F37139.9080303@andyfurniss.entadsl.com> <47F37E04.4010001@trash.net> <47F3B3C5.6000701@andyfurniss.entadsl.com> <47F6062E.9050804@andyfurniss.entadsl.com> <47F606D8.108@trash.net>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Corey Hickey <bugfood-ml@fatooh.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:55702 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751114AbYDDQ7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 12:59:52 -0400
In-Reply-To: <47F606D8.108@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Andy Furniss wrote:

>> I notice allot is short (16bits?) in sfq but see
>>
>> +struct tc_sfq_xstats
>> +{
>> +    __s32        allot;
>> +};
> 
> That doesn't matter, its promoted to a 32 bit value. But now
> that you mention it, the SFQ patch for iproute I submitted
> used a different type. Stephen has resynced it with the kernel
> in the mean time, but you might be using the broken version.

OK - I have the __s32 version in iproute git and in kernel 2.6.25-rc7.

I did have some hassle building iproute2 though, tc built OK once I 
removed ip from the build, so maybe I'll try again over the weekend from 
scratch just incase I messed something up.

Looking at the sfq code it seems that enqueue doesn't init/zero allot 
for a new flow unless it's the first and most of what I see fits with 
this. But rarely it doesn't look like that's all there is to it.

Andy.

