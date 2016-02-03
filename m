From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] of: of_mdio: Add marvell,88e1145 to whitelist of PHY
 compatibilities.
Date: Wed, 3 Feb 2016 21:28:11 +0100
Message-ID: <20160203202811.GB10262@lunn.ch>
References: <1454528129-6144-1-git-send-email-aaro.koskinen@iki.fi>
 <20160203200857.GA10262@lunn.ch>
 <56B25F8D.6070809@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aaro Koskinen <aaro.koskinen@iki.fi>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49199 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754278AbcBCU2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 15:28:18 -0500
Content-Disposition: inline
In-Reply-To: <56B25F8D.6070809@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The compatibility strings may be present in deployed firmware, they
> cannot be removed.  For many OCTEON boards, the device tree is a
> firmware-kernel ABI, it is not practical to unilaterally decide to
> change the bindings on the kernel side as you don't control the
> firmware.

Hi David

We are keeping backwards compatibility. The kernel has always ignored
this string, and will continue to always ignore this string. But since
it is being ignored, you may as well remove it in future versions of
the DTB.

    Andrew
