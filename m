From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [BISECTED] v4.5-rc1 phylib regression
Date: Tue, 26 Jan 2016 23:09:24 +0100
Message-ID: <20160126220924.GK27473@lunn.ch>
References: <20160126044624.GH3880@lunn.ch>
 <20160126121435.GK22974@ak-desktop.emea.nsn-net.net>
 <20160126133417.GI3880@lunn.ch>
 <CAOesGMgaB8R+7jGyLNgQ-M+2nVRhOsEp7LUbiApEEw+dscfL0w@mail.gmail.com>
 <20160126175353.GG27473@lunn.ch>
 <CAOesGMhYU4NOeGRJoF4bcELCFfSsvBVp2du7ZgVjC3QuCv637w@mail.gmail.com>
 <CAOesGMi+ymn_FdDfgTjwgyO-MsEJNGBDU9ayRJvGkjJ7T_ExfA@mail.gmail.com>
 <56A7DB27.6080203@gmail.com>
 <20160126213600.GJ27473@lunn.ch>
 <CAOesGMiEzhN9sGBTq57xnti_Fy1J4rO=djehNHwj47ZhetymXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Aaro Koskinen <aaro.koskinen@nokia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43267 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750756AbcAZWJa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2016 17:09:30 -0500
Content-Disposition: inline
In-Reply-To: <CAOesGMiEzhN9sGBTq57xnti_Fy1J4rO=djehNHwj47ZhetymXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Nope, not an option. Only a small number of DTB actually use c22 or
> > c45. The majority of devices have no compatible at all. Why should
> > they, the binding documentation says it is optional!
> 
> So one thing that can be done is to just have a whitelist in the
> driver that we add the known phy compatibles to, with a nice comment
> above that this should only be for legacy device trees.

So you mean drivers/of/of_mdio.c:of_mdiobus_child_is_phy()
has a white list like:

"brcm,40nm-ephy"
"marvell,88E1111", 
"marvell,88e1116",
"marvell,88e1118",
"marvell,88e1149r",
"marvell,88e1310",
"marvell,88E1510",
"marvell,88E1514",
"moxa,moxart-rtl8201cp",

Yes, that would work.

We should also update the binding documentation to limit what is legal
in the compatible string.

   Andrew
