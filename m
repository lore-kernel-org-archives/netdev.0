From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2013-04-12
Date: Fri, 12 Apr 2013 14:30:05 -0400 (EDT)
Message-ID: <20130412.143005.2249374132456432955.davem@davemloft.net>
References: <1365765117-28316-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1365765117-28316-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri, 12 Apr 2013 13:11:55 +0200

> here's another fix for the v3.9 release cycle, if not too late:
> 
> Christoph Fritz fixed the device tree property handling on little endian
> systems in the sja1000 device tree driver. It was Mylene Josserand who noticed
> that the mcp251x spi CAN driver cannot request its interrupt anymore, as the
> driver is using a threaded interrupt handler without a primary one and without
> specifying IRQF_ONESHOT (which is needed since v3.5). A patch by me fixes this
> problem.

Pulled, thanks Marc.
