From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 3/4] net: stmmac: register parent MDIO node for
 sun8i-h3-emac
Date: Mon, 21 Aug 2017 15:20:15 +0200
Message-ID: <20170821132015.GB1703@lunn.ch>
References: <20170818122118.4925-1-clabbe.montjoie@gmail.com>
 <20170818122118.4925-4-clabbe.montjoie@gmail.com>
 <CAGb2v66KcZkiDDHryMmVzm4WroXePPy3V44SLpVdoO3ZEjgC=g@mail.gmail.com>
 <20170819185025.GB13266@Red>
 <20170819203836.GA21567@lunn.ch>
 <20170820065757.GA6081@Red>
 <20170820142545.GB24150@lunn.ch>
 <CAGb2v67hQXSoCKP7qW+KRUYX+0djQ1Z23cQ67Lyg6G7ozGyfGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Corentin Labbe <clabbe.montjoie@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        devicetree <devicetree@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Chen-Yu Tsai <wens@csie.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGb2v67hQXSoCKP7qW+KRUYX+0djQ1Z23cQ67Lyg6G7ozGyfGQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> With our hardware, and likely Rockchip's as well, the muxed connections
> include the MDIO and MII connections

Ah, i did not realise the MII was muxed as well. Then i agree, an MDIO
mux is wrong.

However, please try to make the binding not look like an mdio mux. We
don't want people misunderstanding the binding and thinking it is an
mdio mux.

     Andrew
