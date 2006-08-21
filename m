From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [Patch] Signedness issue in drivers/net/3c515.c
Date: Mon, 21 Aug 2006 23:13:25 +0100
Message-ID: <1156198406.18887.81.camel@localhost.localdomain>
References: <1156009077.18374.1.camel@alice>
	 <20060821140558.4cfee23c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Sesterhenn <snakebyte@gmx.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:28635 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1751218AbWHUVwz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 17:52:55 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060821140558.4cfee23c.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ar Llu, 2006-08-21 am 14:05 -0700, ysgrifennodd Andrew Morton:
> 	/* Wait for the stall to complete. */
> 	for (i = 20; i >= 0; i--)
> 		if ((inw(ioaddr + EL3_STATUS) & CmdInProgress) == 0) 
> 			break;
> 
> Your fix will convert this indefinit wait into a bounded one.  It might
> cause the driver to malfunction.

The change is correct. The docs guarantee it can't take that long.

