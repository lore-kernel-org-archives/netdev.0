From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] bnx2: Use netif_carrier_off() to prevent timeout.
Date: Mon, 17 May 2010 17:34:56 -0700 (PDT)
Message-ID: <20100517.173456.242125386.davem@davemloft.net>
References: <1273762115-13412-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50213
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753350Ab0ERAer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 20:34:47 -0400
In-Reply-To: <1273762115-13412-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 13 May 2010 07:48:35 -0700

> Based on original patch from Stanislaw Gruszka <sgruszka@redhat.com>.
> 
> Using netif_carrier_off() is better than updating all the ->trans_start
> on all the tx queues.
> 
> netif_carrier_off() needs to be called after bnx2_disable_int_sync()
> to guarantee no race conditions with the serdes timers that can
> modify the carrier state.
> 
> If the chip or phy is reset, carrier will turn back on when we get the
> link interrupt.  If there is no reset, we need to turn carrier back on
> in bnx2_netif_start().  Again, the phy_lock prevents race conditions with
> the serdes timers.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

Applied, thanks.
