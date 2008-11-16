From: David Miller <davem@davemloft.net>
Subject: Re: sfc: Add driverlink API to support virtual NIC drivers
Date: Sun, 16 Nov 2008 00:45:57 -0800 (PST)
Message-ID: <20081116.004557.210684346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43656
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751274AbYKPIp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2008 03:45:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm not applying this patch, it is just a gateway for proprietary
extensions to the driver.

The fact that it allows any module to hook into the driver and
decide how to handle every TX or RX frame basically makes this
change a non-starter.

Many many years ago, various vendor drivers tried to do something
similar, so that their proprietary bonding modules could work,
and instead we improved the Linux bonding driver to have feature
parity with whatever those guys were offering.
