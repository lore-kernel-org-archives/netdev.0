From: Chen-Yu Tsai <wens@csie.org>
Subject: Re: [PATCH v3 2/4] net: stmmac: dwmac-sun8i: choose internal PHY via phy-is-integrated
Date: Sat, 19 Aug 2017 00:58:25 +0800
Message-ID: <CAGb2v643vyUY60fx=XLvK=wGe=_1NWCy6Ff7cGc7O3FzFMLHmw@mail.gmail.com>
References: <20170818122118.4925-1-clabbe.montjoie@gmail.com> <20170818122118.4925-3-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Chen-Yu Tsai <wens@csie.org>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        devicetree <devicetree@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818122118.4925-3-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 18, 2017 at 8:21 PM, Corentin Labbe
<clabbe.montjoie@gmail.com> wrote:
> The current way to find if the phy is internal is to compare DT phy-mode
> and emac_variant/internal_phy.
> But it will negate a possible future SoC where an external PHY use the
> same phy mode than the internal one.
>
> This patch adds a new way to find if the PHY is internal, via
> the phy-is-integrated property.
>
> Since the internal_phy variable does not need anymore to contain the xMII mode
> used by the internal PHY, it is still used for knowing the presence of an
> internal PHY, so it is modified to a boolean soc_has_internal_phy.
>
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Acked-by: Chen-Yu Tsai <wens@csie.org>
