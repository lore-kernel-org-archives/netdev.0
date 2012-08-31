From: David Miller <davem@davemloft.net>
Subject: Re: [Stlinux-devel] [PATCH linux-stm 2/4] net:stmmac: fix broken
 stmmac_pltfr_remove.
Date: Fri, 31 Aug 2012 16:12:54 -0400 (EDT)
Message-ID: <20120831.161254.1967435351723331404.davem@davemloft.net>
References: <1346341819-20125-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com
To: srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755007Ab2HaUM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 16:12:56 -0400
In-Reply-To: <1346341819-20125-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Date: Thu, 30 Aug 2012 16:50:19 +0100

> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> 
> This patch fixes stmmac_pltfr_remove function, which is broken because,
> it is accessing plat variable via freed memory priv pointer which gets
> freed by free_netdev called from stmmac_dvr_remove.
> 
> In short this patch caches the plat pointer in local variable before
> calling stmmac_dvr_remove to prevent code accessing freed memory.
> 
> Without this patch any attempt to remove the stmmac device will fail as
> below:
 ...
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>

Applied.
