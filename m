From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH 3/3] ARM: mvebu: use qsgmii phy-mode for Armada XP GP
 interfaces
Date: Thu, 17 Apr 2014 01:13:17 -0400
Message-ID: <20140417051317.GQ28159@titan.lakedaemon.net>
References: <1397569821-5530-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1397569821-5530-4-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
	George Joseph <george.joseph@fairview5.com>,
	Tawfik Bayouk <tawfik@marvell.com>, netdev@vger.kernel.org,
	Alexander Reuter <Alexander.Reuter@gmx.net>, arno@natisbad.org,
	Willy Tarreau <w@1wt.eu>, Nadav Haklai <nadavh@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Dmitri Epshtein <dima@marvell.com>,
	linux-arm-kernel@lists.infradead.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:43171 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161417AbaDQFNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 01:13:51 -0400
Content-Disposition: inline
In-Reply-To: <1397569821-5530-4-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2014 at 03:50:21PM +0200, Thomas Petazzoni wrote:
> The Armada XP GP isn't using rgmii-id connections between the MAC and
> PHY, but instead a single QSGMII connection, which is a quad-SGMII
> connection: a double pair of differential lines that are multiplexed
> to convey the traffic of four network interfaces between a MAC and a
> PHY.
> 
> Until now, the Armada XP GP was relying on the bootloader setting the
> correct values in various configuration registers. With this change,
> the mvneta driver can be used as a module on this platform.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> ---
>  arch/arm/boot/dts/armada-xp-gp.dts | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)

Applied to mvebu/dt-fixes with Willy and Arnaud's Tested-by's

thx,

Jason.
