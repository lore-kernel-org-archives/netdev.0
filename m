From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 1/2] net: stmmac: Add SOCFPGA glue driver
Date: Wed, 12 Feb 2014 19:35:39 -0500 (EST)
Message-ID: <20140212.193539.38124529344029793.davem@davemloft.net>
References: <1392061697-20193-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	dinh.linux@gmail.com, peppe.cavallaro@st.com, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	vbridgers2013@gmail.com
To: dinguyen@altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbaBMAfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 19:35:41 -0500
In-Reply-To: <1392061697-20193-1-git-send-email-dinguyen@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <dinguyen@altera.com>
Date: Mon, 10 Feb 2014 13:48:16 -0600

> From: Dinh Nguyen <dinguyen@altera.com>
> 
> Like the STi series SOCs, Altera's SOCFPGA also needs a glue layer on top of the
> Synopsys gmac IP.
> 
> This patch adds the platform driver for the glue layer which configures the IP
> before the generic STMMAC driver takes over.
> 
> Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Rob Herring <robh+dt@kernel.org>
> Cc: Pawel Moll <pawel.moll@arm.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Ian Campbell <ijc+devicetree@hellion.org.uk>
> Cc: Kumar Gala <galak@codeaurora.org>
> Cc: Vince Bridgers <vbridgers2013@gmail.com>
> ---
> v3: Remove stray empty line at end of dwmac-socfpga.c.
> v2: Use the dwmac-sti as an example for a glue layer and split patch up
> to have dts as a separate patch. Also cc dts maintainers since there is
> a new binding.

The second patch for the DTS update doesn't apply cleanly at all to
mainline.

Why don't you push both of these patches through whatever tree that
file is maintained under.  You can add my ack:

Acked-by: David S. Miller <davem@davemloft.net>
