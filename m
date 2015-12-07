From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net 1/2] net: cadence: macb: Disable USRIO register on
 some platforms
Date: Mon, 07 Dec 2015 14:09:18 -0500 (EST)
Message-ID: <20151207.140918.1716095197130825314.davem@davemloft.net>
References: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com>
	<1449485914-12883-2-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org, harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449485914-12883-2-git-send-email-narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Date: Mon,  7 Dec 2015 11:58:33 +0100

> -	regs_buff[12] = macb_or_gem_readl(bp, USRIO);
> +	if (!of_property_read_bool(bp->pdev->dev.of_node, "no-usrio")) {
> +		regs_buff[12] = macb_or_gem_readl(bp, USRIO);
> +	}

Single statement basic blocks shall not be enclosed in curly braces.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
