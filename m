From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: fec: clear receive interrupts before
 processing a packet
Date: Wed, 02 Sep 2015 16:07:12 -0700 (PDT)
Message-ID: <20150902.160712.836608694994691635.davem@davemloft.net>
References: <1441185854-16107-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@arm.linux.org.uk, phdm@macq.eu
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897AbbIBXHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 19:07:13 -0400
In-Reply-To: <1441185854-16107-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Wed, 2 Sep 2015 17:24:14 +0800

> From: Russell King <rmk+kernel@arm.linux.org.uk>
> 
> The patch just to re-submit the patch "db3421c114cfa6326" because the
> patch "4d494cdc92b3b9a0" remove the change.
> 
> Clear any pending receive interrupt before we process a pending packet.
> This helps to avoid any spurious interrupts being raised after we have
> fully cleaned the receive ring, while still allowing an interrupt to be
> raised if we receive another packet.
> 
> The position of this is critical: we must do this prior to reading the
> next packet status to avoid potentially dropping an interrupt when a
> packet is still pending.
> 
> Acked-by: Fugang Duan <B38611@freescale.com>
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Applied and queued up for -stable, thanks.
