From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] drivers/net/mlx4: Adjust constant
Date: Sun, 19 Jul 2009 11:24:51 -0700
Message-ID: <1248027891.31365.17.camel@Joe-Laptop.home>
References: <Pine.LNX.4.64.0907191809050.16542@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:2852 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755113AbZGSSY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jul 2009 14:24:57 -0400
In-Reply-To: <Pine.LNX.4.64.0907191809050.16542@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-07-19 at 18:09 +0200, Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> The values in the advertising field are typically ADVERTISED_xxx, not
> SUPPORTED_xxx.  Both SUPPORTED_10000baseT_Full and
> ADVERTISED_1000baseT_Full have the same value.

other possibles:

drivers/net/sungem.c:#define ADVERTISE_MASK	(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full | \
			 SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full | \
			 SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full | \
			 SUPPORTED_Pause | SUPPORTED_Autoneg)
drivers/net/s2io.c:	info->advertising = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
drivers/net/spider_net.c:		advertise |= SUPPORTED_1000baseT_Full;
drivers/net/spider_net.c:		advertise |= SUPPORTED_1000baseT_Half;


