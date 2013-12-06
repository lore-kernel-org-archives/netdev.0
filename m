From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/10] net: stmmac: Use platform data tied with
 compatible strings
Date: Fri, 06 Dec 2013 16:26:33 -0500 (EST)
Message-ID: <20131206.162633.125107323851595113.davem@davemloft.net>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
	<1386350983-13281-4-git-send-email-wens@csie.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	rob.herring@calxeda.com, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-sunxi@googlegroups.com, srinivas.kandagatla@st.com,
	maxime.ripard@free-electrons.com
To: wens@csie.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386350983-13281-4-git-send-email-wens@csie.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chen-Yu Tsai <wens@csie.org>
Date: Sat,  7 Dec 2013 01:29:36 +0800

> +	device = of_match_device(stmmac_dt_ids, &pdev->dev);
> +	if (!device)
> +		return -ENODEV;
> +
> +	if (device->data)
> +	    memcpy(plat, device->data, sizeof(*plat));
> +

Don't invent your own indentation using spaces, this memcpy()
call is not indented properly, it should be two TABs.
