From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] net: Add 405EX support to new EMAC driver
Date: Fri, 2 Nov 2007 11:03:04 -0500
Message-ID: <20071102160304.GA5277@lixom.net>
References: <200711020814.43524.sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	benh@kernel.crashing.org, jwboyer@linux.vnet.ibm.com
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:50919 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753656AbXKBPy0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2007 11:54:26 -0400
Content-Disposition: inline
In-Reply-To: <200711020814.43524.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 02, 2007 at 08:14:43AM +0100, Stefan Roese wrote:
> This patch adds support for the 405EX to the new EMAC driver. Some as on
> AXON, the 405EX handles the MDIO via the RGMII bridge.

Hi,

This isn't feedback on your patch as much as on "new-emac" in general:

Isn't this the case where there should really be device tree properties
instead? If you had an "ibm,emac-has-axon-stacr" property in the device
node, then you don't have to modify the driver for every new board out
there. Same for the other device properties, of course.

I thought this was what having the device tree was all about. :(


-Olof
