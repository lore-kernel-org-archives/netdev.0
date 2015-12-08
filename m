From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH net 2/2] bindings: net: macb: add no-usrio optional
 property
Date: Tue, 8 Dec 2015 09:26:31 -0600
Message-ID: <20151208152631.GA30181@rob-hp-laptop>
References: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com>
 <1449485914-12883-3-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Harini Katakam <harini.katakam@xilinx.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:52897 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752197AbbLHP0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 10:26:36 -0500
Content-Disposition: inline
In-Reply-To: <1449485914-12883-3-git-send-email-narmstrong@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 07, 2015 at 11:58:34AM +0100, Neil Armstrong wrote:
> Add the no-usrio optional property to disable usage of the USRIO
> register on platforms not implementing it.
> ---
>  Documentation/devicetree/bindings/net/macb.txt | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
> index b5d7976..a15ee54 100644
> --- a/Documentation/devicetree/bindings/net/macb.txt
> +++ b/Documentation/devicetree/bindings/net/macb.txt
> @@ -19,6 +19,9 @@ Required properties:
>  	Optional elements: 'tx_clk'
>  - clocks: Phandles to input clocks.
>  
> +Optional properties:
> +- no-usrio: Indicates the platform integration does not implement the USRIO register.

Add a vendor prefix please.

Rob
