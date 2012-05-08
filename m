From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] r8169: fix unsigned int wraparound with TSO
Date: Tue, 08 May 2012 19:35:05 -0400 (EDT)
Message-ID: <20120508.193505.1334053438503113320.davem@davemloft.net>
References: <20120508220006.GA22733@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avillaci@fiec.espol.edu.ec, thomas.pi@arcor.de, jducourt@free.fr,
	hayeswang@realtek.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755065Ab2EHXga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 19:36:30 -0400
In-Reply-To: <20120508220006.GA22733@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 9 May 2012 00:00:06 +0200

> From: Julien Ducourthial <jducourt@free.fr>
> 
> The r8169 may get stuck or show bad behaviour after activating TSO :
> the net_device is not stopped when it has no more TX descriptors.
> This problem comes from TX_BUFS_AVAIL which may reach -1 when all
> transmit descriptors are in use. The patch simply tries to keep positive
> values.
> 
> Tested with 8111d(onboard) on a D510MO, and with 8111e(onboard) on a
> Zotac 890GXITX.
> 
> Signed-off-by: Julien Ducourthial <jducourt@free.fr>
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Applied and queued up for -stable, thanks.
