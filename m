From: Lucas Stach <l.stach@pengutronix.de>
Subject: net: fec: stable queue request
Date: Wed, 21 Oct 2015 15:20:00 +0200
Message-ID: <1445433600.3196.9.camel@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:45374 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754962AbbJUNUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 09:20:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

can you please add

b0c6ce24911fcb64715de9569f0f7b4f54d1d045
net: fec: Remove unneeded use of IS_ERR_VALUE() macro

42ea4457aea7aaeddf0c0b06724f297608f5e9d2
net: fec: normalize return value of pm_runtime_get_sync() in MDIO write

to your stable 4.2+ queue?

Those 2 commits will fix
https://bugzilla.kernel.org/show_bug.cgi?id=106171

Thanks,
Lucas
-- 
Pengutronix e.K.             | Lucas Stach                 |
Industrial Linux Solutions   | http://www.pengutronix.de/  |
