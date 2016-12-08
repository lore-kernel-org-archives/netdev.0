From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH 2/3] net: stmmac: dwmac-generic: add missing
 compatible strings
Date: Thu, 08 Dec 2016 11:35:55 -0500 (EST)
Message-ID: <20161208.113555.708493896423285622.davem@davemloft.net>
References: <1481114469-4788-1-git-send-email-niklass@axis.com>
        <1481114469-4788-2-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com, niklass@axis.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: niklas.cassel@axis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481114469-4788-2-git-send-email-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Wed, 7 Dec 2016 13:41:07 +0100

> From: Niklas Cassel <niklas.cassel@axis.com>
> 
> devicetree binding for stmmac states:
> - compatible: Should be "snps,dwmac-<ip_version>", "snps,dwmac"
> 	For backwards compatibility: "st,spear600-gmac" is also supported.
> 
> Since dwmac-generic.c calls stmmac_probe_config_dt explicitly,
> another alternative would have been to remove all compatible strings
> other than "snps,dwmac" and "st,spear600-gmac" from dwmac-generic.c.
> 
> However, that would probably do more good than harm, since when trying
> to figure out what hardware a certain driver supports, you usually look
> at the compatible strings in the struct of_device_id, and not in some
> function defined in a completely different file.
> 
> No functional change intended.
> 
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
