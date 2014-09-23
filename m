From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 3/9] Documentation: bindings: net: add the Marvell PXA168 Ethernet controller
Date: Tue, 23 Sep 2014 14:38:39 +0200
Message-ID: <51745791.Wuu5QiQB2e@wuerfel>
References: <1411474536-22626-1-git-send-email-antoine.tenart@free-electrons.com> <1411474536-22626-4-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: sebastian.hesselbarth@gmail.com,
	alexandre.belloni@free-electrons.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411474536-22626-4-git-send-email-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 23 September 2014 14:15:30 Antoine Tenart wrote:
> +Optional properties:
> +- port-id: should be '0','1' or '2'.
> +- phy-addr: MDIO address of the PHY.
> +- local-mac-address: see ethernet.txt file in the same directory.
> +
> 

I believe new bindings should not use "phy-addr" properties, but
instead use a phy-handle property pointing to a phy device instead.

The port-id property description could be a little more verbose.
What do those numbers actually mean?

	Arnd
