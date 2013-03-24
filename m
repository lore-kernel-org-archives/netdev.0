From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net/macb: make clk_enable atomic
Date: Sun, 24 Mar 2013 17:08:49 -0400 (EDT)
Message-ID: <20130324.170849.1662647665547155225.davem@davemloft.net>
References: <1363973615-17863-1-git-send-email-s.trumtrar@pengutronix.de>
	<1363973615-17863-3-git-send-email-s.trumtrar@pengutronix.de>
	<CAOMZO5BRDU_-fvv4PZQcLe-4OdZ4bDQ8m+nNHEFcC1Y2+zdh9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: s.trumtrar@pengutronix.de, netdev@vger.kernel.org,
	nicolas.ferre@atmel.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754646Ab3CXVIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 17:08:50 -0400
In-Reply-To: <CAOMZO5BRDU_-fvv4PZQcLe-4OdZ4bDQ8m+nNHEFcC1Y2+zdh9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Fri, 22 Mar 2013 14:38:39 -0300

> On Fri, Mar 22, 2013 at 2:33 PM, Steffen Trumtrar
> <s.trumtrar@pengutronix.de> wrote:
>> Use clk_prepare_enable to be safe on SMP systems.
> 
> Wouldn't you have to use clk_disable_unprepare() now?

Indeed I think he does.
