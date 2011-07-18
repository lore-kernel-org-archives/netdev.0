From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] stmmac: add memory barriers at appropriate places
Date: Mon, 18 Jul 2011 10:47:38 -0700 (PDT)
Message-ID: <20110718.104738.1276525421191328605.davem@davemloft.net>
References: <1310972049-827-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shiraz.hashim@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991Ab1GRRrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 13:47:46 -0400
In-Reply-To: <1310972049-827-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon, 18 Jul 2011 08:54:08 +0200

> From: Shiraz Hashim <shiraz.hashim@st.com>
> 
> This patch, provided by ST SPEAr developers,
> has fixed a problem raised on ARM CA9 where
> happened that the dma_transmission was enabled before
> the dma descriptors were properly filled. To guarantee this
> data memory barriers have been explicity used in the driver.
> 
> Signed-off-by: Shiraz Hashim <shiraz.hashim@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
