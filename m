From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: testing crazy stuff with iproute2
Date: Thu, 27 Dec 2007 22:09:01 +0100
Message-ID: <4774146D.1030502@gmail.com>
References: <20071226045037.M75814@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:40976 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbXL0VFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 16:05:39 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1708817ugc.16
        for <netdev@vger.kernel.org>; Thu, 27 Dec 2007 13:05:37 -0800 (PST)
In-Reply-To: <20071226045037.M75814@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote, On 12/26/2007 05:57 AM:
...

> But i got few times in dmesg, during tests (probably when i set sfq instead 
> pfifo, or etc).
> 
> [2090816.116000] htb: class 10003 isn't work conserving ?!
> 
> Is it a bug? And does it worth to do such "shaper"?

It's not a bug - htb simply wonders the sub-queue has packets,
but doesn't dequeue any when expected. Probably htb + tbf isn't
the most common configuration, but nothing wrong either. You
should only consider htb could do similar (not exactly) job by
itself, and each additional qdisc adds some latency, so it's only
a question of priorities. But, hmm, ...don't you think this
lartc.org's mailing list is really nice?

Regards,
Jarek P.

PS: BTW, maybe I missed this, but I hoped you'd share here some
impressions from testing this new PSPacer scheduler?
