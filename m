From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH,RFC] ep93xx_eth: conversion to phylib framework
Date: Sun, 24 Feb 2008 12:23:03 +0100
Message-ID: <20080224112303.GA21025@xi.wantstofly.org>
References: <1195205900-24481-1-git-send-email-hvr@gnu.org> <A8AEF70B-2B76-4F62-A930-ABCA9E9E7475@freescale.com> <1203841313.24522.13.camel@pbook.intra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org
To: Herbert Valerio Riedel <hvr@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:35627 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883AbYBXLXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2008 06:23:06 -0500
Content-Disposition: inline
In-Reply-To: <1203841313.24522.13.camel@pbook.intra>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 24, 2008 at 09:21:53AM +0100, Herbert Valerio Riedel wrote:

> > > Currently, the ep93xx_eth driver doesn't care about the PHY state,
> > > but it should, in order to tell the MAC when full duplex operation is
> > > required; failure to do so causes degraded performance on full duplex
> > > links. This patch implements proper PHY handling via the phylib  
> > > framework:
> > >
> > >  - clean up ep93xx_mdio_{read,write} to conform to ep93xx manual
> > >  - convert ep93xx_eth driver to phylib framework
> > >  - set full duplex bit in configuration of MAC when FDX link detected
> > >  - convert to use print_mac()
> > 
> > Looks good to me.  My only comment is that we might want to have  
> > support for checking preamble suppression support in the PHY Lib,  
> > itself.
> > 
> > Acked-by: Andy Fleming <afleming@freescale.com>
> 
> ...as nothing happend for some months now just wondering, what I should
> do next, to get this patch merged upstream :-)

ACK!
