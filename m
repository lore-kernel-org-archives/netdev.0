From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: stmmac: Handle possible fixed-link with
 need_mdio_ids
Date: Fri, 25 Aug 2017 18:28:27 +0200
Message-ID: <20170825162827.GA4207@lunn.ch>
References: <20170825144208.24503-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170825144208.24503-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 25, 2017 at 04:42:08PM +0200, Corentin Labbe wrote:
> In case of fixed link, there are no mdio node.
> This patch add a test for fixed-link for bypassing MDIO node register.

The two are not mutually exclusive. E.g.
vf610-zii-dev.dtsi/vf610-zii-dev-rev-b.dts.  It has a fixed-link on
the FEC ethernet controller, and an Ethernet switch on the MDIO bus.

If anybody ever wants to use a switch with the stmmac, this will be
required.

	Andrew
