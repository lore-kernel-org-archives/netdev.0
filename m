From: Anders Darander <anders.darander@datarespons.se>
Subject: Re: [PATCH][V2] MACB: Set PHY address in kernel parameters
Date: Wed, 31 Mar 2010 11:39:56 +0200
Message-ID: <20100331093956.GI4837@datarespons.se>
References: <1270025218-7245-1-git-send-email-anders.darander@gmail.com>
 <4BB31345.5050101@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Haavard Skinnemoen <hskinnemoen@atmel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Erik Waling <erik.waling@konftel.com>,
	Patrick McHardy <kaber@trash.net>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BB31345.5050101@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Marc Kleine-Budde <mkl@pengutronix.de> [100331 11:18]:
> We're using phy_mask in one of our projects, it's still using 2.6.29,
> though. I think it's worth testing if it's still working.

Well, that was obviously something I overlooked / misinterpreted when I
tried to solve our problem!

As I understand it, phy_mask is a bitfield for setting which PHYs should
be enabled... Then this should have worked OK for us!

> static struct at91_eth_data __initdata p298_macb_data = {
>        .is_rmii        = 0,
>        .phy_mask       = ~(1 << 8),
> };

> at91_add_device_eth(&p298_macb_data);

I've not tested it, but it should probably have worked.

Regards,
Anders
