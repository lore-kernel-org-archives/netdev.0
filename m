From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v2 resend 2/2] net: fec: introduce fec_ptp_stop and use
 in probe fail path
Date: Sun, 26 Jul 2015 21:52:08 -0700 (PDT)
Message-ID: <20150726.215208.179930290498377059.davem@davemloft.net>
References: <1437660380-21164-1-git-send-email-l.stach@pengutronix.de>
	<1437660380-21164-2-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@freescale.com, Frank.Li@freescale.com,
	netdev@vger.kernel.org, patchwork-lst@pengutronix.de
To: l.stach@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38120 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbbG0EwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 00:52:09 -0400
In-Reply-To: <1437660380-21164-2-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <l.stach@pengutronix.de>
Date: Thu, 23 Jul 2015 16:06:20 +0200

> This function frees resources and cancels delayed work item that
> have been initialized in fec_ptp_init().
> 
> Use this to do proper error handling if something goes wrong in
> probe function after fec_ptp_init has been called.
> 
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> Acked-by: Fugang Duan <B38611@freescale.com>

Applied.
