From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.34-rc6] net: Improve ks8851 snl transmit performance
Date: Mon, 24 May 2010 10:44:50 -0700 (PDT)
Message-ID: <20100524.104450.178799105.davem@davemloft.net>
References: <14385191E87B904DBD836449AA30269D021A64@MORGANITE.micrel.com>
	<20100516.002607.84408834.davem@davemloft.net>
	<14385191E87B904DBD836449AA30269D6DF528@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@simtec.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, x0066660@ti.com, s-jan@ti.com
To: Tristram.Ha@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34536
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757721Ab0EXRoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 13:44:44 -0400
In-Reply-To: <14385191E87B904DBD836449AA30269D6DF528@MORGANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Date: Mon, 24 May 2010 10:28:40 -0700

> As the socket buffer is accepted by the lowest level network driver and
> reaches the end of its life, I think using one of its variables
> temporarily does not cause any harm.

The packet can be referenced by packet sniffers and other entities in
the kernel.
