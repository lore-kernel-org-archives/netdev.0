From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: restart the FEC when PHY speed changes
Date: Fri, 15 Mar 2013 08:47:34 -0400 (EDT)
Message-ID: <20130315.084734.1157021927559145476.davem@davemloft.net>
References: <1363273921-5035-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Frank.Li@freescale.com
To: l.stach@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754322Ab3COMrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 08:47:18 -0400
In-Reply-To: <1363273921-5035-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <l.stach@pengutronix.de>
Date: Thu, 14 Mar 2013 16:12:01 +0100

> Proviously we would only restart the FEC when PHY link or duplex state
> changed. PHY does not always bring down the link for speed changes, in
> which case we would not detect any change and keep FEC running.
> 
> Switching link speed without restarting the FEC results in the FEC being
> stuck in an indefinite state, generating error conditions for every
> packet.
> 
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>

Applied.
