From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: bus id in PHY Abstraction Layer
Date: Wed, 9 May 2007 10:45:56 +0200
Message-ID: <20070509084556.GA5967@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: afleming@freescale.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.extern.pengutronix.de ([83.236.181.26]:47061 "EHLO
	metis.extern.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754607AbXEIIqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 04:46:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I made a quick shot to port the at91 network driver to the phy
abstraction layer. While doing so I stumbled upon the
(struct mii_bus)->id field. Currently the network driver registering the
bus has to set this field. au1000_eth.c for example uses 0 or 1. mii-fec.c
uses the id field of the corresponding platform device, which will start
from 0, too. So if a second ethernet driver comes around the id fields
will clash. I think the PAL has to assign the id field instead of the
network driver. Maybe a id convention like "mii_fec.x:yy" where x is a
running number and yy is the phy address would do it. Any opinions about
that?

Sascha

-- 
Pengutronix - Linux Solutions for Science and Industry
Entwicklungszentrum Nord     http://www.pengutronix.de
