From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 3/4] net: stmmac: register parent MDIO node for
 sun8i-h3-emac
Date: Fri, 25 Aug 2017 15:26:30 +0200
Message-ID: <20170825132630.GA28171@lunn.ch>
References: <20170822181140.GA11596@Red>
 <352ae66b-78a4-e88b-4544-a8edd9390b0c@gmail.com>
 <20170823074942.yt3c5gvnmdw5pqge@flea.home>
 <f14fe754-6339-32a0-3439-2daff6dd1d7e@gmail.com>
 <20170824082124.GA14302@Red>
 <dfc8e7f3-e374-b30b-b320-017f1c50ab58@gmail.com>
 <CAGb2v64jrDPSff+QL_PQBMaQJ+CcTVbskjuOUd1OqR4smbu+ig@mail.gmail.com>
 <77ff97c1-9d0a-8b3f-d0b9-25c951f86fec@gmail.com>
 <CAGb2v64Bx7vzzK8nKbiQPsYkgu5JZ6_0iCkx=mgpWY=8b_GeXQ@mail.gmail.com>
 <3d74f0e3-9baf-195d-1e59-dbd8210b3c6f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chen-Yu Tsai <wens@csie.org>,
        Corentin Labbe <clabbe.montjoie@gmail.com>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        devicetree <devicetree@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3d74f0e3-9baf-195d-1e59-dbd8210b3c6f@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Just tested. Yes the MDIO/MDC lines are also muxed and controlled through
> > the same mux bit.
> 
> Alright then the mdio-mux seems appropriate, thanks.

Please add a comment that it muxes the MII lines as well.  That is not
normal for an mdio-mux, so we should document it in the dtsi file.

Thanks
       Andrew
