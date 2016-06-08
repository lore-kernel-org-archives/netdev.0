From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v2 2/2] Documentation: DT: cpsw: remove rx_descs property
Date: Wed, 8 Jun 2016 15:11:38 -0500
Message-ID: <20160608201138.GA17007@rob-hp-laptop>
References: <1465307976-12235-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1465307976-12235-3-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mugunthanvnm@ti.com, linux-kernel@vger.kernel.org,
	grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	bcousson@baylibre.com, tony@atomide.com, devicetree@vger.kernel.org
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34748 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754152AbcFHULk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 16:11:40 -0400
Content-Disposition: inline
In-Reply-To: <1465307976-12235-3-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 04:59:36PM +0300, Ivan Khoronzhuk wrote:
> There is no reason to hold s/w dependent parameter in device tree.
> Even more, there is no reason in this parameter because davinici_cpdma
> driver splits pool of descriptors equally between tx and rx channels
> anyway.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> ---
>  Documentation/devicetree/bindings/net/cpsw.txt | 1 -
>  arch/arm/boot/dts/am33xx.dtsi                  | 1 -
>  arch/arm/boot/dts/am4372.dtsi                  | 1 -
>  arch/arm/boot/dts/dm814x.dtsi                  | 1 -
>  arch/arm/boot/dts/dra7.dtsi                    | 1 -
>  5 files changed, 5 deletions(-)

Acked-by: Rob Herring <robh@kernel.org>
