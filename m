From: David Miller <davem@davemloft.net>
Subject: Re: net: stmmac: dwmac-rk: fixes for Wake-on-Lan on RK3288
Date: Fri, 10 Jun 2016 18:16:46 -0700 (PDT)
Message-ID: <20160610.181646.1722421370385177808.davem@davemloft.net>
References: <bd302fc6-feae-b99a-4632-a0ff9ead0123@st.com>
	<1465606839-7722-1-git-send-email-vpalatin@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch, dianders@chromium.org, peppe.cavallaro@st.com,
	heiko@sntech.de, zhengsq@rock-chips.com
To: vpalatin@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465606839-7722-1-git-send-email-vpalatin@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vincent Palatin <vpalatin@chromium.org>
Date: Fri, 10 Jun 2016 18:00:36 -0700

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

Ignore my previous email, but in the future please tag these postings
properly with "[PATCH 0/N] " at the beginning of the subject line.

Thanks.
