From: David Miller <davem@davemloft.net>
Subject: Re: Configuring ethernet link fails with No such device
Date: Mon, 11 Apr 2016 21:29:00 -0400 (EDT)
Message-ID: <20160411.212900.1164760179761034053.davem@davemloft.net>
References: <67b662523c63277fa95a59472cbf018f@agner.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: systemd-devel@lists.freedesktop.org, netdev@vger.kernel.org,
	fabio.estevam@freescale.com, l.stach@pengutronix.de,
	u.kleine-koenig@pengutronix.de, bryan.wu@canonical.com,
	bob.ham@collabora.com
To: stefan@agner.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbcDLB3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 21:29:03 -0400
In-Reply-To: <67b662523c63277fa95a59472cbf018f@agner.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Agner <stefan@agner.ch>
Date: Mon, 11 Apr 2016 15:46:08 -0700

> What is the expectation/definition when link configuration should be
> possible? Only after the network device got opened or before?

Only after it is open.  Drivers almost always have the entire chip in
powerdown state when it is not open, so we wouldn't be able to
properly do link settings even if we wanted to when the device is
closed.
