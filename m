From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net 2/2] net: phy: micrel: Restore led_mode and clk_sel
 on resume
Date: Wed, 31 May 2017 14:52:26 -0700
Message-ID: <49f66bd1-80f4-ca41-d2a6-eecb189bdebb@gmail.com>
References: <cover.1496224930.git.leonard.crestez@nxp.com>
 <1460beebce4ba23722cfb185b0f9f884cca3b9e9.1496224930.git.leonard.crestez@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andy Duan <fugang.duan@nxp.com>, Johan Hovold <johan@kernel.org>,
        Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Philipp Zabel <p.zabel@pengutronix.de>,
        Fabio Estevam <fabio.estevam@nxp.com>, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Leonard Crestez <leonard.crestez@nxp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Shawn Guo <shawnguo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460beebce4ba23722cfb185b0f9f884cca3b9e9.1496224930.git.leonard.crestez@nxp.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/31/2017 03:29 AM, Leonard Crestez wrote:
> These bits seem to be lost after a suspend/resume cycle so just set them
> again. Do this by splitting the handling of these bits into a function
> that is also called on resume.
> 
> This patch fixes ethernet suspend/resume on imx6ul-14x14-evk boards.
> 
> Signed-off-by: Leonard Crestez <leonard.crestez@nxp.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
