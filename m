From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 2/4] net: stmmac: dwmac-sun8i: choose internal PHY via
 phy-is-integrated
Date: Tue, 22 Aug 2017 09:40:32 -0700
Message-ID: <2e7f8dec-2d7f-6e1a-a462-226dcd023724@gmail.com>
References: <20170818122118.4925-1-clabbe.montjoie@gmail.com>
 <20170818122118.4925-3-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>, robh+dt@kernel.org,
        mark.rutland@arm.com, linux@armlinux.org.uk,
        maxime.ripard@free-electrons.com, wens@csie.org,
        peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818122118.4925-3-clabbe.montjoie@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/18/2017 05:21 AM, Corentin Labbe wrote:
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

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
