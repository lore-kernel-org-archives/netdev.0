From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2013-03-27
Date: Wed, 27 Mar 2013 14:10:45 -0400 (EDT)
Message-ID: <20130327.141045.999210087722896364.davem@davemloft.net>
References: <1364393128-19701-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1364393128-19701-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 27 Mar 2013 15:05:26 +0100

> Hello David,
> 
> here's a patch series for net for the v3.9 release cycle. Fengguang Wu found
> two problems with the sja1000 drivers:
> 
> A macro in the SH architecture collides with one in the sja1000 driver. I
> created a minimal patch suited for stable, only changing this particular
> define. (Once net is merged back to net-next, I'll post a patch to uniformly
> use a SJA1000_ prefix for the sja100 private defines.) If you prefer, I can
> squash both patches together.
> 
> Fengguang further noticed that the peak pcmcia driver will not compile on archs
> without ioport support. I created a patch to limit the driver to archs which
> select HAS_IOPORT in Kconfig.

Pulled, thanks Marc.
