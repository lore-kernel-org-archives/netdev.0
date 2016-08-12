From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH RFCv2] net: ethernet: macb: Add support for rx_clk
Date: Fri, 12 Aug 2016 14:03:18 -0500
Message-ID: <20160812190318.GA17752@rob-hp-laptop>
References: <1470996979-33015-1-git-send-email-shubhrajyoti.datta@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	soren.brinkmann@xilinx.com, shubhrajyoti.datta@gmail.com,
	michal.simek@xilinx.com
To: Shubhrajyoti Datta <shubhrajyoti.datta@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34197 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbcHLTDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 15:03:20 -0400
Content-Disposition: inline
In-Reply-To: <1470996979-33015-1-git-send-email-shubhrajyoti.datta@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2016 at 03:46:19PM +0530, Shubhrajyoti Datta wrote:
> Some of the platforms like zynqmp ultrascale+ has a
> separate clock gate for the rx clock. Add an optional
> rx_clk so that the clock can be enabled.
> 
> Signed-off-by: Shubhrajyoti Datta <shubhrajyoti.datta@xilinx.com>
> ---
> v2:
> fix warning
> 
>  Documentation/devicetree/bindings/net/macb.txt |  2 +-
>  drivers/net/ethernet/cadence/macb.c            | 31 +++++++++++++++++++++-----
>  drivers/net/ethernet/cadence/macb.h            |  4 +++-
>  3 files changed, 30 insertions(+), 7 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
> index b5a42df..315beda 100644
> --- a/Documentation/devicetree/bindings/net/macb.txt
> +++ b/Documentation/devicetree/bindings/net/macb.txt
> @@ -20,7 +20,7 @@ Required properties:
>  - phy-mode: See ethernet.txt file in the same directory.
>  - clock-names: Tuple listing input clock names.
>  	Required elements: 'pclk', 'hclk'
> -	Optional elements: 'tx_clk'
> +	Optional elements: 'tx_clk', 'rx_clk'

Please state which compatibles this applies to.

>  - clocks: Phandles to input clocks.
>  
>  Optional properties for PHY child node:
