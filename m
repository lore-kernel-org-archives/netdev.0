From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] net: phy: Don't use drv when it is NULL in
 phy_attached_print
Date: Mon, 21 Aug 2017 12:45:36 +0300
Message-ID: <5c7d444c-427f-7a4d-8603-02bd4dc4b909@cogentembedded.com>
References: <20170821075235.28473-1-romain.perier@collabora.com>
 <20170821075235.28473-3-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Romain Perier <romain.perier@collabora.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821075235.28473-3-romain.perier@collabora.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 8/21/2017 10:52 AM, Romain Perier wrote:

> Currently, if this logging function is used prior the phy driver is
> binded to the phy device (that is usually done from .ndo_open),

    s/binded/bound/.

> 'phydev->drv' might be NULL, resulting in a kernel crash. That is
> typically the case in the stmmac driver, info about the phy is displayed
> during the registration of the MDIO bus, and then genphy driver is binded

    Likewise.

> to this phydev when .ndo_open is called.
> 
> This commit fixes the issue by using the right genphy driver, when
> phydev->drv is NULL.
> 
> Fixes: commit fbca164776e4 ("net: stmmac: Use the right logging functi")

    "Commit" not needed here.

> Signed-off-by: Romain Perier <romain.perier@collabora.com>
[...]

MBR, Sergei
