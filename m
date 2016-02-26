From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 03/12] net-next: mediatek: add embedded switch driver
 (ESW)
Date: Fri, 26 Feb 2016 18:05:45 +0100
Message-ID: <20160226170545.GE12022@lunn.ch>
References: <1456496504-50429-1-git-send-email-blogic@openwrt.org>
 <1456496504-50429-4-git-send-email-blogic@openwrt.org>
 <20160226151813.GD12022@lunn.ch>
 <56D06E3F.1020100@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Fred Chang (?????????)" <Fred.Chang@mediatek.com>,
	"Steven Liu (?????????)" <steven.liu@mediatek.com>,
	netdev@vger.kernel.org,
	"Carlos Huang (?????????)" <Carlos.Huang@mediatek.com>,
	linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
	Matthias Brugger <matthias.bgg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: John Crispin <blogic@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56D06E3F.1020100@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> the problem here is that on one side people complain about vendors not
> sending code upstream. once they start being a good citizen and provide
> funding to send stuff upstream the feedback tends to be very bad as seen
> here. we are planning on doing a DSA driver but one step at a time. this
> kind of feedback will inevitably lead to vendors doing second thoughts
> of upstream contributions.

I think it is great a vendor is providing funding to get code
upstream. However, that code needs to conform with current kernel
architecture and design philosophy.

We as a community also need to be consistent. We have recently push
back on Microchip with there LAN9352 who want to do something very
similar, introduce the MAC and a very dumb switch driver. They are now
looking at what it means to do a DSA driver. There is also talk of
writing a DSA driver for the ks8995 family.

As David said recently, a year ago this probably would of been
accepted. But now, switches need to be DSA or switchdev.

	  Andrew
