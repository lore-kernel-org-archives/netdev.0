From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Tue, 09 Jun 2009 09:25:48 +0400
Message-ID: <4A2DF25C.7030109@bigtelecom.ru>
References: <4A252714.2020008@trash.net> <20090602213723.GB2850@ami.dom.local> <4A259EB2.5010500@gmail.com> <4A2620FD.8030708@trash.net> <20090603074049.GA5254@ff.dom.local> <4A262BE7.4090807@trash.net> <20090603095412.GC5644@ff.dom.local> <298f5c050906040650y31de6fdcv865e775d52bc977c@mail.gmail.com> <20090604193013.GA2755@ami.dom.local> <4A282216.20203@trash.net> <20090604194203.GB2755@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Antonio Almeida <vexwek@gmail.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:43516 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150AbZFIFbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 01:31:53 -0400
In-Reply-To: <20090604194203.GB2755@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!
Do you have any progress to apply this patch set?
I'm very interested to view that patches in mainline kernel tree. We
would like to use HTB for speeds more than 1G (converts 10 servers x 1G
to few with 10G intel multi queue network devices).

Thanks for you doing!
Best regals, Slavon

> On Thu, Jun 04, 2009 at 09:35:50PM +0200, Patrick McHardy wrote:
>   
>> Jarek Poplawski wrote:
>>     
> ...
>   
>>> OK, I'll browse other schedulers, and if there is nothing suspicious
>>> I'll submit these patches.
>>>       
>> Please give me a day to have another look at this, I didn't find
>> any time today.
>>
>> In most areas the overflows are only occuring when crossing
>> IMO unreasonable boundaries (but I've been wrong about that
>> before), but tc_cbq_calc_maxidle() is still making me nervous.
>>     
>
> Sure, I planned similar time for browsing it yet, as well.
>
> Thanks,
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   

