From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: ethernet: Add TSE PCS support to dwmac-socfpga
Date: Sun, 05 Jun 2016 23:11:02 -0400 (EDT)
Message-ID: <20160605.231102.1130873370221997319.davem@davemloft.net>
References: <1464944835-21575-1-git-send-email-thloh@altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	peppe.cavallaro@st.com, dinguyen@altera.com, thloh85@gmail.com,
	cnphoon@altera.com, phooncn@gmail.com
To: thloh@altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464944835-21575-1-git-send-email-thloh@altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <thloh@altera.com>
Date: Fri, 3 Jun 2016 02:07:15 -0700

> From: Tien Hock Loh <thloh@altera.com>
> 
> This adds support for TSE PCS that uses SGMII adapter when the phy-mode of
> the dwmac is set to sgmii
> 
> Signed-off-by: Tien Hock Loh <thloh@altera.com>

Please at least make an effort to use consistent coding style.

You rework this function to do this:

> -	if (!splitter_base)
> -		return;
> +	if (splitter_base) {

And then you add something like this:

> +	if ((tse_pcs_base) && (sgmii_adapter_base)) {
> +		tse_pcs_fix_mac_speed(&dwmac->pcs, phy_dev, speed);
> +	}

Excessive parenthesis in the if() condition, and single statement
basic blocks do not get curly braces.
