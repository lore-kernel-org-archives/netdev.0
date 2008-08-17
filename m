From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sun, 17 Aug 2008 15:36:08 +0200
Message-ID: <20080817133608.GA3584@ami.dom.local>
References: <20080815190905.M56388@visp.net.lb> <20080817123825.GE2907@ami.dom.local> <200808171550.01154.denys@visp.net.lb> <200808171603.22151.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.180]:27950 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbYHQNeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 09:34:37 -0400
Received: by ik-out-1112.google.com with SMTP id c28so1870800ika.5
        for <netdev@vger.kernel.org>; Sun, 17 Aug 2008 06:34:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808171603.22151.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 17, 2008 at 04:03:22PM +0300, Denys Fedoryshchenko wrote:
> All patches applied.
> On normal shaper i got just this warning mentioned before.
> On alternative shaper (it is not using TBF anymore, it is using flow 
> classifier and many HTB classes) - it is panicing. 
> 
> After applying all rules, most probably it is happened when some traffic 
> passed over there. I can't be absolutely sure in that, but it looks like at 
> that time there is no actions by iproute2/tc done. Just traffic.
> 
> This is same PC where WARNING appeared which i mention in previous mail. So 
> maybe it is result of that warning, no idea... 

BTW, I'll have to have a break for today, so I'll be able to respond
only tomorrow. Your testing is very valuable and this all needs
rethinking, but as before, I doubt current -rc is good choice for
production.

Cheers,
Jarek P.
