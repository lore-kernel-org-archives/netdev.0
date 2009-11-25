From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] igb and ixgbe: DOM support cleanups
Date: Tue, 24 Nov 2009 20:30:43 -0800
Message-ID: <1259123443.29779.20.camel@Joe-Laptop.home>
References: <19211.4849.284727.703717@gargle.gargle.HOWL>
	 <1259017659.16503.138.camel@Joe-Laptop.home>
	 <19212.8726.367568.937773@gargle.gargle.HOWL>
	 <1259121454.29779.17.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: robert@herjulf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1170 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932739AbZKYEah (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 23:30:37 -0500
In-Reply-To: <1259121454.29779.17.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-11-24 at 19:57 -0800, Joe Perches wrote:
> +	if (eo & DOM_EO_AW) {
> +		for (i = 0; i < ARRAY_SIZE(basic); i++) {
> +			res = read_phy_diag(hw, 0x1, aw[i].reg,
> +					    (u16 *)((char *)pd + aw[i].offset));
> +			if (res)
> +				goto out;
> +		}

[]

> +	if (eo & DOM_EO_AW) {
> +		for (i = 0; i < ARRAY_SIZE(basic); i++) {
> +			res = read_phy_diag(hw, 0x1, aw[i].reg,
> +					    (u16 *)((char *)pd + aw[i].offset));
> +			if (res)
> +				goto out;
> +		}
> +	}

Rotten patches.  These should be ARRAY_SIZE(aw).


