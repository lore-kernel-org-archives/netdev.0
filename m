From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RESEND] [PATCH] tcp: fix for splice receive when used with software LRO
Date: Sat, 21 Jun 2008 13:32:15 +0300
Message-ID: <200806211332.15944.opurdila@ixiacom.com>
References: <485B4ADE.8070102@domat.com.pl> <200806210340.48479.opurdila@ixiacom.com> <20080621083900.GA2488@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4055 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751950AbYFUKdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 06:33:49 -0400
In-Reply-To: <20080621083900.GA2488@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 21 June 2008, Jarek Poplawski wrote:

>
> Hmm..., I hope my ack will not hinder too much...
>

No, it actually helped making this a better patch and me learning a great 
deal.


> PS: I see this other "readability" patch seems to change even more, so
> I'll really need some free time to figure this out.
>

Sure, no hurry. To be honest this is a rewrite which I started to see if I 
understand the tcp read splice path properly. It ended up being cleaner than 
the original code so I thought I should share this - but of course being the 
one who wrote it I am completely biased on that assessment. So if it is not 
obviously more "readable" to someone else, than its probably not worth 
spending too much time on it  since we already have working / tested code :)

Thanks,
tavi
