From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] net: stmmac: dwmac-rk: fixes for Wake-on-Lan on
 RK3288
Date: Thu, 16 Jun 2016 14:15:14 -0700 (PDT)
Message-ID: <20160616.141514.2135278107149916159.davem@davemloft.net>
References: <CAP_ceTxFuCsqRQJ_9GMc5PSKqczA8Qwaa0jX22wQ2Dq=+GZUuQ@mail.gmail.com>
	<cover.1466015458.git.vpalatin@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch, dianders@chromium.org, peppe.cavallaro@st.com,
	heiko@sntech.de, zhengsq@rock-chips.com
To: vpalatin@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1466015458.git.vpalatin@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vincent Palatin <vpalatin@chromium.org>
Date: Wed, 15 Jun 2016 11:32:20 -0700

> In order to support Wake-On-Lan when using the RK3288 integrated MAC
> (with an external RGMII PHY), we need to avoid shutting down the regulator
> of the external PHY when the MAC is suspended as it's currently done in the MAC
> platform code.
> As a first step, create independant callbacks for suspend/resume rather than
> re-using exit/init callbacks. So the dwmac platform driver can behave differently
> on suspend where it might skip shutting the PHY and at module unloading.
> Then update the dwmac-rk driver to switch off the PHY regulator only if we are
> not planning to wake up from the LAN.
> Finally add the PMT interrupt to the MAC device tree configuration, so we can
> wake up the core from it when the PHY has received the magic packet.
> 
> Changes since v1:
>   * rename 'powered_down' variable into 'suspended'.
>   * fix the logic recording the PHY suspended state according to Heiko comments.

Series applied to net-next, thanks.
