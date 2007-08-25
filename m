From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH] via-velocity: more cleanup
Date: Sat, 25 Aug 2007 02:18:03 +0100
Message-ID: <20070825011803.GY21089@ftp.linux.org.uk>
References: <20070824135649.509e1fe7@freepuppy.rosehill.hemminger.net> <20070824211547.GW21089@ftp.linux.org.uk> <20070824144045.087d41ff@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54862 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753764AbXHYBSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 21:18:07 -0400
Content-Disposition: inline
In-Reply-To: <20070824144045.087d41ff@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 24, 2007 at 02:40:45PM -0700, Stephen Hemminger wrote:
> +static void mac_set_vlan_cam(struct mac_regs __iomem * regs, int idx,
> +			     const u8 *addr)

ITYM const u16 *, if not an outright u16.  These casts (one below and
ones in callers) really should die.

> +	writew(*((u16 *) addr), &regs->MARCAM[0]);
