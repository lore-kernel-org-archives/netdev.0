From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4 0/5] net: stmmac: Improve mcast/ucast filter for
 snps
Date: Thu, 31 Jul 2014 14:13:57 -0700 (PDT)
Message-ID: <20140731.141357.559911187001982866.davem@davemloft.net>
References: <1406839757-10905-1-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	peppe.cavallaro@st.com, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org,
	robh+dt@kernel.org, dinguyen@altera.com, vbridger@altera.com
To: vbridgers2013@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51063 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbaGaVN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 17:13:58 -0400
In-Reply-To: <1406839757-10905-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridgers2013@gmail.com>
Date: Thu, 31 Jul 2014 15:49:12 -0500

> This patch series adds Synopsys specific bindings for the Synopsys EMAC
> filter characteristics since those are implementation dependent. The
> multicast and unicast filtering code was improved to handle different
> configuration variations based on device tree settings. 
> 
> I verified the operation of the multicast and unicast filters through 
> Synopsys support as requested during the V1 review, and tested the GMAC
> configuration on an Altera Cyclone 5 SOC (which supports 256 multicast
> bins and 128 Unicast addresses). The 10/100 variant of this driver
> modification was not tested, although it was compile tested. I shared
> the email thread results of the investigation through Synopsys with the
> stmmac maintainer.

Series applied to net-next, thanks Vince.
