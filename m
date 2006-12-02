From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] 2.6 driver for Silan SC92031
Date: Sat, 02 Dec 2006 17:27:51 -0500
Message-ID: <4571FDE7.9060203@pobox.com>
References: <4571FC49.5060208@cesarb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:22975 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S936569AbWLBW1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Dec 2006 17:27:55 -0500
To: Cesar Eduardo Barros <cesarb@cesarb.net>
In-Reply-To: <4571FC49.5060208@cesarb.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cesar Eduardo Barros wrote:
> From: Cesar Eduardo Barros <cesarb@cesarb.net>
> 
> This is a driver for the Silan SC92031/Rsltek 8139D NIC chip. It's a
> rewrite of the vendor 2.4 driver for 2.6, and has been lightly tested
> on a 2.6.17 x86-64 kernel with the Ubuntu patches (as a out-of-tree
> module only).
> 
> This chip is found on at least one counterfeit Encore ENL832-TX-RENT
> NIC [1], which came with a mini-CD with the 2.4 driver. A slightly
> older version of the driver was found at [2]. The main difference
> between them is that the newer one has a small bugfix in the RX path,
> a lot of gratuitous renaming of functions, all the printable strings
> changed to show as a "Rsltek 8139D" [sic], and a PCI ID of 8139 instead
> of 2031.
> 
> This patch has been modified to apply cleanly on 2.6.19; to run on
> 2.6.17, just add back the struct pt_regs* argument to the interrupt
> handler and to its call at poll_controller(). It compiles on 2.6.19 for
> x86-64 as a module.
> 
> [1] See http://www.encore-usa.com/faq.php under ENL832-TX-RENT for more
>     information
> [2] Look for SL_LINUX.ZIP (which is really a .tar.gz) at
>     http://broadbandforum.in/dataone_Intex_LAN_cardlinux-t4207-s15.html
> 
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>

Seems like it would be best to modify the existing 8139 driver...

	Jeff



