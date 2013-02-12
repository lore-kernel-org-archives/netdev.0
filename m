From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fec_mpc52xx: Read MAC address from device-tree
Date: Tue, 12 Feb 2013 16:15:26 -0500 (EST)
Message-ID: <20130212.161526.1610493155978768216.davem@davemloft.net>
References: <1360660088-27464-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, agust@denx.de
To: sr@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244Ab3BLVP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 16:15:29 -0500
In-Reply-To: <1360660088-27464-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Roese <sr@denx.de>
Date: Tue, 12 Feb 2013 10:08:08 +0100

> Until now, the MPC5200 FEC ethernet driver relied upon the bootloader
> (U-Boot) to write the MAC address into the ethernet controller
> registers. The Linux driver should not rely on such a thing. So
> lets read the MAC address from the DT as it should be done here.
> 
> The following priority is now used to read the MAC address:
> 
> 1) First, try OF node MAC address, if not present or invalid, then:
> 
> 2) Read from MAC address registers, if invalid, then:
> 
> 3) Log a warning message, and choose a random MAC address.
> 
> This fixes a problem with a MPC5200 board that uses the SPL U-Boot
> version without FEC initialization before Linux booting for
> boot speedup.
> 
> Additionally a status line is now be printed upon successful
> driver probing, also displaying this MAC address.
> 
> Signed-off-by: Stefan Roese <sr@denx.de>

Applied.
