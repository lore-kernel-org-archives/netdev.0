From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] macb: Remove inappropriate spinlocks around mii calls
Date: Sat, 17 Feb 2007 15:31:13 -0500
Message-ID: <45D76611.3060801@garzik.org>
References: <11716379462542-git-send-email-hskinnemoen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Victor <andrew@sanpeople.com>,
	Patrice Vilchez <patrice.vilchez@rfo.atmel.com>,
	David Brownell <dbrownell@users.sourceforge.net>
To: Haavard Skinnemoen <hskinnemoen@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47790 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932166AbXBQUbR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 15:31:17 -0500
In-Reply-To: <11716379462542-git-send-email-hskinnemoen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Haavard Skinnemoen wrote:
> Remove spin_lock_irqsave() around mii_ethtool_gset, mii_ethtool_sset
> and generic_mii_ioctl. These are unnecessary and harmful because
> the mii calls may call back into the mdio functions, which may sleep.
> 
> Pointed out by David Brownell.
> 
> Signed-off-by: Haavard Skinnemoen <hskinnemoen@atmel.com>
> ---
>  drivers/net/macb.c |   24 +++---------------------
>  1 files changed, 3 insertions(+), 21 deletions(-)

applied


