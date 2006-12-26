From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 3/7] driver for Silan SC92031 netdev
Date: Tue, 26 Dec 2006 16:42:29 -0500
Message-ID: <45919745.4080106@garzik.org>
References: <200612192108.kBJL8l4u010493@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cesarb@cesarb.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41584 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932818AbWLZVmd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 16:42:33 -0500
To: akpm@osdl.org
In-Reply-To: <200612192108.kBJL8l4u010493@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Cesar Eduardo Barros <cesarb@cesarb.net>
> 
> This is a driver for the Silan SC92031/Rsltek 8139D NIC chip.
> 
> This chip is found on at least one counterfeit Encore ENL832-TX-RENT NIC
> [1], which came with a mini-CD with the 2.4 driver.  A slightly older
> version of the driver was found at [2].  The main difference between them
> is that the newer one has a small bugfix in the RX path, a lot of
> gratuitous renaming of functions, all the printable strings changed to show
> as a "Rsltek 8139D" [sic], and a PCI ID of 8139 instead of 2031.  The
> driver on this patch is a rewrite of the vendor drivers (based mostly on
> the older one).
> 
> Changes from the previous patch sent to netdev:
> - Use MMIO instead of PIO
> - Changed TX bounce buffers allocation
> - Use skb_copy_and_csum_dev
> - Several small bug fixes
> - Tested for more than just a few minutes each time
> 
> [1] See http://www.encore-usa.com/faq.php under ENL832-TX-RENT for more
>     information
> [2] Look for SL_LINUX.ZIP (which is really a .tar.gz) at
>     http://broadbandforum.in/dataone_Intex_LAN_cardlinux-t4207-s15.html
> [3] To compile on 2.6.17, simply add back the last argument to the
>     interrupt handler in two places, and copy the boolean declarations
>     from 2.6.19
> 
> [akpm@osdl.org: build fixes]
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

applied


