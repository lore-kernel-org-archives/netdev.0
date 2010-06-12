From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: Broken rndis_host with #define DEBUG (by
	a475f603d23392f386e45cf377b17c30ed3bbb80)
Date: Sat, 12 Jun 2010 23:39:07 +0300
Message-ID: <20100612233907.2036688tfjxqq9hc@hayate.sektori.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"David Brownell" <dbrownell@users.sourceforge.net>
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sirokuusama.dnainternet.net ([83.102.40.133]:46081 "EHLO
	sirokuusama.dnainternet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752343Ab0FLUjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jun 2010 16:39:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Commit a475f603d23392f386e45cf377b17c30ed3bbb80 "drivers/net/usb: Use  
netif_<level> logging facilities" causes problems with rndis_host.

rndis_host oopses with #define DEBUG, in generic_rndis_bind() when  
calling netif_dbg(). Problem is that (netdev)->dev.parent is NULL  
(used in netdev_printk) while generic_rndis_bind is called.

-Jussi

