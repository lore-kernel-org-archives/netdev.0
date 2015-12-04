From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 2/5] stmmac: Correct documentation on stmmac clocks.
Date: Fri, 4 Dec 2015 10:18:07 -0600
Message-ID: <20151204161807.GA10180@rob-hp-laptop>
References: <1449220125-67417-1-git-send-email-preid@electromag.com.au>
 <1449220125-67417-3-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	davem@davemloft.net
To: Phil Reid <preid@electromag.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:56388 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754665AbbLDQSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 11:18:11 -0500
Content-Disposition: inline
In-Reply-To: <1449220125-67417-3-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 04, 2015 at 05:08:42PM +0800, Phil Reid wrote:
> devm_get_clk looks in clock-name property for matching clock.
> the ptp_ref_clk property is ignored.
> 
> Signed-off-by: Phil Reid <preid@electromag.com.au>

Acked-by: Rob Herring <robh@kernel.org>

> ---
>  Documentation/devicetree/bindings/net/stmmac.txt | 17 ++++++++---------
>  1 file changed, 8 insertions(+), 9 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> index 0056c4c..060e2d5 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -35,15 +35,14 @@ Optional properties:
>  - reset-names: Should contain the reset signal name "stmmaceth", if a
>  	reset phandle is given
>  - max-frame-size: See ethernet.txt file in the same directory
> -- clocks: If present, the first clock should be the GMAC main clock and
> -  the second clock should be peripheral's register interface clock. Further
> -  clocks may be specified in derived bindings.
> -- clock-names: One name for each entry in the clocks property, the
> -  first one should be "stmmaceth" and the second one should be "pclk".
> -- clk_ptp_ref: this is the PTP reference clock; in case of the PTP is
> -  available this clock is used for programming the Timestamp Addend Register.
> -  If not passed then the system clock will be used and this is fine on some
> -  platforms.
> +- clocks: If present, the first clock should be the GMAC main clock
> +  The optional second clock should be peripheral's register interface clock.
> +  The third optional clock should be the ptp reference clock. 
> +  Further clocks may be specified in derived bindings.
> +- clock-names: One name for each entry in the clocks property.
> +  The first one should be "stmmaceth".
> +  The optional second one should be "pclk".
> +  The optional third one should be "clk_ptp_ref".
>  - snps,burst_len: The AXI burst lenth value of the AXI BUS MODE register.
>  - tx-fifo-depth: See ethernet.txt file in the same directory
>  - rx-fifo-depth: See ethernet.txt file in the same directory
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
