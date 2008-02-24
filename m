From: Herbert Valerio Riedel <hvr@gnu.org>
Subject: Re: [PATCH,RFC] ep93xx_eth: conversion to phylib framework
Date: Sun, 24 Feb 2008 09:21:53 +0100
Message-ID: <1203841313.24522.13.camel@pbook.intra>
References: <1195205900-24481-1-git-send-email-hvr@gnu.org>
	 <A8AEF70B-2B76-4F62-A930-ABCA9E9E7475@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lennert Buytenhek <buytenh@wantstofly.org>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx05.kabsi.at ([195.202.128.131]:35727 "EHLO mx05.kabsi.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752120AbYBXIqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Feb 2008 03:46:45 -0500
In-Reply-To: <A8AEF70B-2B76-4F62-A930-ABCA9E9E7475@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello *

On Wed, 2007-11-21 at 11:54 -0600, Andy Fleming wrote:
> On Nov 16, 2007, at 03:38, Herbert Valerio Riedel wrote:
> 
> > Currently, the ep93xx_eth driver doesn't care about the PHY state,
> > but it should, in order to tell the MAC when full duplex operation is
> > required; failure to do so causes degraded performance on full duplex
> > links. This patch implements proper PHY handling via the phylib  
> > framework:
> >
> >  - clean up ep93xx_mdio_{read,write} to conform to ep93xx manual
> >  - convert ep93xx_eth driver to phylib framework
> >  - set full duplex bit in configuration of MAC when FDX link detected
> >  - convert to use print_mac()
> 
> Looks good to me.  My only comment is that we might want to have  
> support for checking preamble suppression support in the PHY Lib,  
> itself.
> 
> Acked-by: Andy Fleming <afleming@freescale.com>

...as nothing happend for some months now just wondering, what I should
do next, to get this patch merged upstream :-)

cheers,
hvr

