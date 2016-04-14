From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ethernet: stmmac: GMAC4.xx: Fix TX
 descriptor preparation
Date: Wed, 13 Apr 2016 22:43:48 -0400 (EDT)
Message-ID: <20160413.224348.277274080784977510.davem@davemloft.net>
References: <1460107083-25577-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	dan.carpenter@oracle.com, kernel-janitors@vger.kernel.org
To: alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754082AbcDNCnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 22:43:50 -0400
In-Reply-To: <1460107083-25577-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandre TORGUE <alexandre.torgue@st.com>
Date: Fri, 8 Apr 2016 11:18:03 +0200

> On GMAC4.xx each descriptor contains 2 buffers of 16KB (each).
> Initially, those 2 buffers was filled in dwmac4_rd_prepare_tx_desc but
> it is actually not needed. Indeed, stmmac driver supports frame up to
> 9000 bytes (jumbo). So only one buffer is needed.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

Applied.
