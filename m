From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v2 1/3] dt/net: add helper function of_get_phy_mode
Date: Mon, 21 Nov 2011 11:57:32 +0100
Message-ID: <4ECA2E9C.1000207@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "'linux-arm-kernel@lists.infradead.org'"
	<linux-arm-kernel@lists.infradead.org>, netdev@vger.kernel.org,
	Rob Herring <robherring2@gmail.com>
To: Shawn Guo <shawn.guo@freescale.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	devicetree-discuss@lists.ozlabs.org,
	devicetree-discuss@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from newsmtp5.atmel.com ([204.2.163.5]:13498 "EHLO
	sjogate2.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063Ab1KUK6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 05:58:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

> It adds the helper function of_get_phy_mode getting phy interface
> from device tree.
> 
> Signed-off-by: Shawn Guo <shawn.guo <at> linaro.org>
> Cc: Grant Likely <grant.likely <at> secretlab.ca>
> ---
>  drivers/of/of_net.c    |   43 +++++++++++++++++++++++++++++++++++++++++++
>  include/linux/of_net.h |    1 +

[..]

> +const int of_get_phy_mode(struct device_node *np)

Nice helper function, indeed.

> +{
> +	const char *pm;
> +	int err, i;
> +
> +	err = of_property_read_string(np, "phy-mode", &pm);

Just a quick question about the use of the "phy-mode" string: 
- I know that it is widely used in drivers
- but, I discovered that in the ePAPR the string mentioned is "phy-connection-type" (6.5.2.2)
- and it is true also that in the very same document, we find the "phy-mode" in the Appendix B1 example...

Why this naming is not consistent (even in ePAPR)?

Best regards,
-- 
Nicolas Ferre
