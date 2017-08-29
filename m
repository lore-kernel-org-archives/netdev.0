From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 4/5] net: stmmac: dwmac-sun8i: choose internal PHY via
 phy-is-integrated
Date: Tue, 29 Aug 2017 16:06:25 +0200
Message-ID: <20170829140625.GA8235@lunn.ch>
References: <20170826073311.25612-1-clabbe.montjoie@gmail.com>
 <20170826073311.25612-5-clabbe.montjoie@gmail.com>
 <20170826212051.GA10418@lunn.ch>
 <20170829083432.GA28818@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org,
        f.fainelli@gmail.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux@armlinux.org.uk,
        linux-kernel@vger.kernel.org, wens@csie.org, robh+dt@kernel.org,
        peppe.cavallaro@st.com, maxime.ripard@free-electrons.com,
        linux-arm-kernel@lists.infradead.org, icenowy@aosc.io
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170829083432.GA28818@Red>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Do you agree that another mdio_mux_init() must be written ? (taking
> a of_node (in our case: mdio-mux) instead of a device)

Yes, you are correct, it is using dev->of_node. So you need to
refactor the code a little, to allow an of_node to be passed.

	 Andrew
