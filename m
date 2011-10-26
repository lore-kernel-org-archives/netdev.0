From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] stmmac: update normal descriptor structure
Date: Wed, 26 Oct 2011 17:23:36 -0400 (EDT)
Message-ID: <20111026.172336.2194646960980073121.davem@davemloft.net>
References: <1319637339-14866-1-git-send-email-peppe.cavallaro@st.com>
	<1319637339-14866-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, keguang.zhang@gmail.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42411 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139Ab1JZVXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 17:23:43 -0400
In-Reply-To: <1319637339-14866-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 26 Oct 2011 15:55:39 +0200

> This patch updates the normal descriptor structure
> to work fine on new GMAC Synopsys chips.
> 
> Normal descriptors were designed on the old MAC10/100
> databook 1.91 where some bits were reserved: for example
> the tx checksum insertion and rx checksum offload.
> 
> The patch maintains the back-compatibility with old
> MAC devices (tested on STx7109 MAC10/100) and adds new
> fields that actually new GMAC devices can use.
> 
> For example, STx7109 (MAC10/100) will pass from the platform
>   tx_coe = 0, enh_desc = 0, has_gmac = 0.
> A platform like Loongson1B (GMAC) will pass:
>   tx_coe = 1, enh_desc = 0, has_gmac = 1.
> 
> Thanks to Kelvin, he enhanced the normal descriptors for
> GMAC (on MIPS Loongson1B platform).
> 
> Signed-off-by: Kelvin Cheung <keguang.zhang@gmail.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
