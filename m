From: David Miller <davem@davemloft.net>
Subject: Re: [net-next resend PATCH 1/6] net: cpsw: enhance pinctrl support
Date: Wed, 22 May 2013 23:57:41 -0700 (PDT)
Message-ID: <20130522.235741.135665074490271750.davem@davemloft.net>
References: <1369130103-743-1-git-send-email-mugunthanvnm@ti.com>
	<1369130103-743-2-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-omap@vger.kernel.org, benoit.cousson@linaro.orgm,
	paul@pwsan.com, gururaja.hebbar@ti.com
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51626 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417Ab3EWG5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 02:57:42 -0400
In-Reply-To: <1369130103-743-2-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Tue, 21 May 2013 15:24:58 +0530

> +		priv->pins_default = pinctrl_lookup_state(priv->pinctrl,
> +						PINCTRL_STATE_DEFAULT);

This is not indented correctly.

Argument on the second, and subsequent, lines of a function call
must start at the first column after the openning parenthesis of
the function call itself.

Please audit for this problem in your entire patch series, fix
it up, and resubmit the full set of patches.

Thanks.
