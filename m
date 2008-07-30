From: David Miller <davem@davemloft.net>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 14:35:32 -0700 (PDT)
Message-ID: <20080730.143532.124324888.davem@davemloft.net>
References: <200807301939.m6UJd5lT012610@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com, mpm@selenic.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53129
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751585AbYG3Vfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 17:35:32 -0400
In-Reply-To: <200807301939.m6UJd5lT012610@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 30 Jul 2008 12:39:04 -0700

> From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> 
> Add the CONFIG_ETHTOOL option which allows to remove support for ethtool,
> not necessarly used on embedded systems.  As this is a size-reduction
> option, it depends on CONFIG_EMBEDDED.  It allows to save ~6 kilobytes of
> kernel code:
> 
>    text	   data	    bss	    dec	    hex	filename
> 1258447	 123592	 212992	1595031	 185697	vmlinux
> 1252147	 123592	 212992	1588731	 183dfb	vmlinux.new
>   -6300       0       0   -6300   -189C +/-
> 
> Question: should we also remove ethtool-related functions from all network
> drivers ?
> 
> This patch has been originally written by Matt Mackall
> <mpm@selenic.com>, and is part of the Linux Tiny project.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

There is no way I'm applying this, ever.

This change means you can't configure nearly all of the features on
your ethernet card.  You can't even configure the link parameters
without ethtool support.

If you want 6K back get rid of the random number generator, I hear
embedded people don't need that either :-)
