From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 03/12] net-next: mediatek: add embedded switch driver
 (ESW)
Date: Fri, 26 Feb 2016 16:18:13 +0100
Message-ID: <20160226151813.GD12022@lunn.ch>
References: <1456496504-50429-1-git-send-email-blogic@openwrt.org>
 <1456496504-50429-4-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
	Matthias Brugger <matthias.bgg@gmail.com>,
	"Steven Liu (?????????)" <steven.liu@mediatek.com>,
	"Carlos Huang (?????????)" <Carlos.Huang@mediatek.com>,
	"Fred Chang (?????????)" <Fred.Chang@mediatek.com>
To: John Crispin <blogic@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43783 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754142AbcBZPSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 10:18:21 -0500
Content-Disposition: inline
In-Reply-To: <1456496504-50429-4-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2016 at 03:21:35PM +0100, John Crispin wrote:
> The ESW is found in many of the old 100mbit MIPS based SoCs. it has 5
> external ports, 1 cpu port and 1 further port that the internal HW
> offloading engine connects to.
> 
> This driver is very basic and only provides basic init and irq support.
> The SoC and switch core both have support for a special tag making DSA
> support possible.

Hi Crispin

There was recently a discussion about adding switches without using
DSA or switchdev. It was pretty much decided we would not accept such
drivers.

Sorry

	Andrew
