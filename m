From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net: stmmac: Add SOCFPGA glue driver
Date: Fri, 28 Mar 2014 15:07:06 -0400 (EDT)
Message-ID: <20140328.150706.1512982620713301379.davem@davemloft.net>
References: <1395891912-26855-1-git-send-email-dinguyen@altera.com>
	<1395891912-26855-2-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dinh.linux@gmail.com, arnd@arndb.de, peppe.cavallaro@st.com,
	srinivas.kandagatla@st.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, arm@kernel.org,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	devicetree@vger.kernel.org
To: dinguyen@altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782AbaC1THK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 15:07:10 -0400
In-Reply-To: <1395891912-26855-2-git-send-email-dinguyen@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <dinguyen@altera.com>
Date: Wed, 26 Mar 2014 22:45:10 -0500

> From: Dinh Nguyen <dinguyen@altera.com>
> 
> Like the STi and sunxi series SOCs, Altera's SOCFPGA also needs a glue layer
> on top of the Synopsys gmac IP.
> 
> This patch adds the platform driver for the glue layer which configures the IP
> before the generic STMMAC driver takes over.
> 
> Signed-off-by: Dinh Nguyen <dinguyen@altera.com>

Applied, although:

> +	struct device_node *np	= dev->of_node;

I had to fix that TAB between "np" and "=" into a space.
