From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 3/4] net: stmmac: register parent MDIO node for
 sun8i-h3-emac
Date: Sat, 19 Aug 2017 22:38:36 +0200
Message-ID: <20170819203836.GA21567@lunn.ch>
References: <20170818122118.4925-1-clabbe.montjoie@gmail.com>
 <20170818122118.4925-4-clabbe.montjoie@gmail.com>
 <CAGb2v66KcZkiDDHryMmVzm4WroXePPy3V44SLpVdoO3ZEjgC=g@mail.gmail.com>
 <20170819185025.GB13266@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chen-Yu Tsai <wens@csie.org>, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        devicetree <devicetree@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170819185025.GB13266@Red>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 19, 2017 at 08:50:25PM +0200, Corentin Labbe wrote:
> On Sat, Aug 19, 2017 at 01:05:21AM +0800, Chen-Yu Tsai wrote:
> > On Fri, Aug 18, 2017 at 8:21 PM, Corentin Labbe
> > <clabbe.montjoie@gmail.com> wrote:
> > > In case of a MDIO switch, the registered MDIO node should be
> > > the parent of the PHY. Otherwise of_phy_connect will fail.

Hi Corentin

Sorry, I missed this patch series. Looking at patchwork...

Can you represent the MDIO mux using 

Documentation/devicetree/bindings/net/mdio-mux-mmioreg.txt

It would be better if you could reuse existing infrastructure than
invent something new.

   Andrew
