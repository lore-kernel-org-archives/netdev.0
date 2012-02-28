From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] ARM: LPC32xx: Ethernet driver
Date: Tue, 28 Feb 2012 13:11:06 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E83@saturn3.aculab.com>
References: <4F4CD1D8.8030102@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <alexander.h.duyck@intel.com>, <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <eilong@broadcom.com>,
	"Kevin Wells" <kevin.wells@nxp.com>,
	"Wolfram Sang" <w.sang@pengutronix.de>,
	<jeffrey.t.kirsher@intel.com>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: "Roland Stigge" <stigge@antcom.de>, <baruch@tkos.co.il>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4F4CD1D8.8030102@antcom.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> Thanks for the note! I actually found out that in many cases, the
> bootloader already initialized the hardware with the target 
> MAC address so we can use this one.
> 
> For the case that it _isn't_ initialized already, is it the right
thing
> to use a hard coded default MAC address to be replaced by the final
one
> in userspace? (I found such examples in some current micrel/ and amd/
drivers.)

Using a fixed address is a very bad idea ...

	David
