From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Fix tg3_poll_controller() passing wrong pointer
 to tg3_interrupt()
Date: Wed, 10 Mar 2010 07:33:37 -0800 (PST)
Message-ID: <20100310.073337.124043070.davem@davemloft.net>
References: <1268151281-15012-1-git-send-email-louis.rilling@kerlabs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	stable@kernel.org
To: louis.rilling@kerlabs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53843
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756739Ab0CJPdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 10:33:17 -0500
In-Reply-To: <1268151281-15012-1-git-send-email-louis.rilling@kerlabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Louis Rilling <louis.rilling@kerlabs.com>
Date: Tue,  9 Mar 2010 17:14:41 +0100

> [Resending without buggy address for stable. Sorry.]
> 
> Commit 09943a1819a240ff4a72f924d0038818fcdd0a90
> 	Author: Matt Carlson <mcarlson@broadcom.com>
> 	Date:   Fri Aug 28 14:01:57 2009 +0000
> 
> 	tg3: Convert ISR parameter to tnapi
> 
> forgot to update tg3_poll_controller(), leading to intermittent crashes with
> netpoll.
> 
> Fix this.
> 
> Signed-off-by: Louis Rilling <louis.rilling@kerlabs.com>
> Cc: stable@kernel.org

Applied, thanks.
