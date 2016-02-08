From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/7] net: phy: spi_ks8995: add register initialization
Date: Mon, 8 Feb 2016 09:54:13 +0100
Message-ID: <20160208085413.GA1820@lunn.ch>
References: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
 <1454884753-4560-4-git-send-email-helmut.buchsbaum@gmail.com>
 <56B81BC1.6090904@gmail.com>
 <56B851C8.4080401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51645 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972AbcBHIyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 03:54:17 -0500
Content-Disposition: inline
In-Reply-To: <56B851C8.4080401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> At the moment I use this driver with a KSZ8795CLX, port 5 directly
> connected to a MACB/GEM of a Zynq SOC, with the need to enable the
> RGMII internal clock delay (register 0x56,  bit 4), otherwise the
> the Zynq cannot talk to the switch on its RGMII interface

Hi Helmut

This is possible with DSA.
Documentation/devicetree/bindings/net/dsa/dsa.txt says you can include
a phy-mode setting. phy-mode is defined in
Documentation/devicetree/bindings/net/ethernet.txt and includes
"rgmii-id", "rgmii-rxid", "rgmii-txid" which control these delays.

    Andrew
