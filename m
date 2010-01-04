From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can/netlink: add CAN_CTRLMODE_ONE_SHOT
Date: Sun, 03 Jan 2010 21:31:55 -0800 (PST)
Message-ID: <20100103.213155.165813602.davem@davemloft.net>
References: <1261567668-21692-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	wg@grandegger.com
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40700
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752602Ab0ADFbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:31:52 -0500
In-Reply-To: <1261567668-21692-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 23 Dec 2009 12:27:48 +0100

> This patch adds the flag CAN_CTRLMODE_ONE_SHOT. It is used as mask
> or flag in the "struct can_ctrlmode".
> 
> It allows userspace via netlink to set a CAN controller into the special
> "one-shot" mode. In this mode, if supported by the CAN controller, it
> tries only once to deliver a CAN frame and aborts it if an error
> (e.g.: arbitration lost) happens.
> 
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> Acked-by: Wolfgang Grandegger <wg@grandegger.com>

Applied.
