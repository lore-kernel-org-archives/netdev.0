From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: convert mvneta to build_skb()
Date: Mon, 15 Jul 2013 17:30:49 +0200
Message-ID: <20130715153049.GE6844@1wt.eu>
References: <20130704173552.GA23370@1wt.eu> <20130715163408.4064699f@skate> <20130715151240.GD6844@1wt.eu> <20130715172321.61e8c237@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:34652 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932272Ab3GOPau (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jul 2013 11:30:50 -0400
Content-Disposition: inline
In-Reply-To: <20130715172321.61e8c237@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ removing Eric from Cc who's probably not interested by this ]

On Mon, Jul 15, 2013 at 05:23:21PM +0200, Thomas Petazzoni wrote:
> The big-endian support is pretty light in terms of driver changes, so
> if there are conflicts, they should be easy to solve.

I agree.

BTW, I'm still having the patch to re-enable phy-polling at boot in my
queue. Last time I tried without it I still only had eth0 working. I
completely forgot about this one. Since I did it blindly, I have no way
to verify if what I've done is necessary according to the specs. But I'm
quite sure that the NICs that are not enabled by the boot loaders don't
work.

If you want, I'll resend it to you at the same time.

Best regards,
Willy
