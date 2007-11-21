From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH,RFC] ep93xx_eth: conversion to phylib framework
Date: Wed, 21 Nov 2007 11:54:47 -0600
Message-ID: <A8AEF70B-2B76-4F62-A930-ABCA9E9E7475@freescale.com>
References: <1195205900-24481-1-git-send-email-hvr@gnu.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lennert Buytenhek <buytenh@wantstofly.org>
To: Herbert Valerio Riedel <hvr@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:50136 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbXKURzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 12:55:38 -0500
In-Reply-To: <1195205900-24481-1-git-send-email-hvr@gnu.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Nov 16, 2007, at 03:38, Herbert Valerio Riedel wrote:

> Currently, the ep93xx_eth driver doesn't care about the PHY state,
> but it should, in order to tell the MAC when full duplex operation is
> required; failure to do so causes degraded performance on full duplex
> links. This patch implements proper PHY handling via the phylib  
> framework:
>
>  - clean up ep93xx_mdio_{read,write} to conform to ep93xx manual
>  - convert ep93xx_eth driver to phylib framework
>  - set full duplex bit in configuration of MAC when FDX link detected
>  - convert to use print_mac()

Looks good to me.  My only comment is that we might want to have  
support for checking preamble suppression support in the PHY Lib,  
itself.

Acked-by: Andy Fleming <afleming@freescale.com>
