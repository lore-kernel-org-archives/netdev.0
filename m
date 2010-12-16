From: Kristian Larsson <kristian@spritelink.net>
Subject: Re: pktgen IP address stepping
Date: Thu, 16 Dec 2010 22:11:54 +0100
Message-ID: <20101216211153.GA8658@spritelink.se>
References: <20101216172800.GA8404@spritelink.se>
 <1292522532.29894.33.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Mail2.SpriteLink.NET ([195.182.5.83]:50043 "EHLO
	Mail2.SpriteLink.NET" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793Ab0LPVNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 16:13:32 -0500
Content-Disposition: inline
In-Reply-To: <1292522532.29894.33.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 10:02:12AM -0800, Joe Perches wrote:
> pr_<foo> calls are already prefixed with pktgen via pr_fmt,
> you don't need to add it to the format string.

I can see at least two different cases of debug statements;

    if (debug)
        pr_info("Delay set at: %llu ns\n", pkt_dev->delay);


    if (debug)
        printk(KERN_DEBUG "pktgen: dst_min set to: %s\n",
               pkt_dev->dst_min);


what's the reasoning behind using one or the other?

   -K

-- 
Kristian Larsson                                        KLL-RIPE
+46 704 264511			              kll@spritelink.net
