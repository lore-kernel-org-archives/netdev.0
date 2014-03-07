From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/5] IBM Akebono: Add support for a new PHY interface
 to the IBM emac driver
Date: Fri, 07 Mar 2014 15:41:42 -0500 (EST)
Message-ID: <20140307.154142.488351276799532264.davem@davemloft.net>
References: <1394077948-8395-1-git-send-email-alistair@popple.id.au>
	<1394077948-8395-3-git-send-email-alistair@popple.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394077948-8395-3-git-send-email-alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alistair Popple <alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org>
Date: Thu,  6 Mar 2014 14:52:25 +1100

> +	out_be32(dev->reg, in_be32(dev->reg) | WKUP_ETH_RGMIIEN
> +		 | WKUP_ETH_TX_OE | WKUP_ETH_RX_IE);

When an expression spans multiple lines, the lines should end with
operators rather than begin with them.

Also, it would be easier to read this call if parenthesis were put
around the third argument and then indented to match, f.e.:

	out_be32(dev->reg, (in_be32(dev->reg) | WKUP_ETH_RGMIIEN |
			    WKUP_ETH_TX_OE | WKUP_ETH_RX_IE));
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
