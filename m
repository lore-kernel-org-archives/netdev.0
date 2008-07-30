From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 13:37:27 -0700
Message-ID: <20080730133727.7774de6a@extreme>
References: <200807301939.m6UJd5lT012610@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	thomas.petazzoni@free-electrons.com, davem@davemloft.net,
	mpm@selenic.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:39176 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750793AbYG3UhT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 16:37:19 -0400
In-Reply-To: <200807301939.m6UJd5lT012610@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jul 2008 12:39:04 -0700
akpm@linux-foundation.org wrote:

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

This option needs to be forced on when bridging or bonding is selected.

