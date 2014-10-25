From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 06/14] net: dsa: Add support for hardware monitoring
Date: Sat, 25 Oct 2014 20:00:16 +0200
Message-ID: <20141025180016.GA13191@lunn.ch>
References: <20141023134706.GB25190@lunn.ch>
 <20141023162754.GA21343@roeck-us.net>
 <20141023165459.GE25190@lunn.ch>
 <20141023173847.GA22988@roeck-us.net>
 <20141023180357.GG25190@lunn.ch>
 <20141023184322.GA24281@roeck-us.net>
 <20141023195526.GH25190@lunn.ch>
 <20141024161919.GA29600@roeck-us.net>
 <20141025140116.GA12051@lunn.ch>
 <544BDC8F.2030308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, Guenter Roeck <linux@roeck-us.net>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43680 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752408AbaJYTQj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Oct 2014 15:16:39 -0400
Content-Disposition: inline
In-Reply-To: <544BDC8F.2030308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 25, 2014 at 10:23:27AM -0700, Florian Fainelli wrote:
> On 10/25/14 07:01, Andrew Lunn wrote:
> >> Here is another naming option:
> >>
> >> em1dsa0-virtual-0
> > 
> > I prefer this over isa.
> > 
> > However, i think there should be some sort of separator between the
> > network device name and dsa.
> 
> Considering that network devices can be renamed, do we want it to be
> included in the sensor name at all?

Well, we need something which identifies the "DSA collection". In
that, you could have two or more collections, connected to different
network devices.

I once came across a PCI board with two Intel ethernet chipsets and
two 10 port Marvell switches. Each switch had one host cpu port, 3
ports interconnected to the other switch, and 6 going to the back
panel.  You would want to describe that as two separate DSA entities,
not one DSA with two switches. So the name needs something to indicate
the DSA collection.

	Andrew
