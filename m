From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] stmmac: fix max coal timer parameter
Date: Tue, 09 Dec 2014 13:25:40 -0500 (EST)
Message-ID: <20141209.132540.799020666207755138.davem@davemloft.net>
References: <1417606378-8179-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbaLISZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:25:43 -0500
In-Reply-To: <1417606378-8179-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Wed, 3 Dec 2014 12:32:58 +0100

> This patch is to fix the max coalesce timer setting that can be provided
> by ethtool.
> The default value (STMMAC_COAL_TX_TIMER) was used in the set_coalesce helper
> instead of the max one (STMMAC_MAX_COAL_TX_TICK, so defined but not used).
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
