From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 1/4] natsemi: Add support for using MII port with no PHY
Date: Thu, 16 Mar 2006 01:09:02 -0800
Message-ID: <20060316010902.57e3a98b.akpm@osdl.org>
References: <20060312192259.929734000@mercator.sirena.org.uk>
	<20060312205303.869316000@mercator.sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: thockin@hockin.org, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752187AbWCPJL6@vger.kernel.org>
To: Mark Brown <broonie@sirena.org.uk>
In-Reply-To: <20060312205303.869316000@mercator.sirena.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Brown <broonie@sirena.org.uk> wrote:
>
>  +	if (np->ignore_phy && (ecmd->autoneg == AUTONEG_ENABLE ||
>  +			       ecmd->port == PORT_INTERNAL)) {

What's PORT_INTERNAL?  ethtool doesn't appear to define that.

drivers/net/natsemi.c: In function `netdev_set_ecmd':
drivers/net/natsemi.c:2989: `PORT_INTERNAL' undeclared (first use in this function)
drivers/net/natsemi.c:2989: (Each undeclared identifier is reported only once
drivers/net/natsemi.c:2989: for each function it appears in.)
