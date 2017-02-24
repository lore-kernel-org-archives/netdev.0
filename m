From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: unify registers dumps methods
Date: Fri, 24 Feb 2017 11:13:40 -0500 (EST)
Message-ID: <20170224.111340.2250960229537472520.davem@davemloft.net>
References: <20170223131225.5420-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751356AbdBXQNn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 11:13:43 -0500
In-Reply-To: <20170223131225.5420-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Thu, 23 Feb 2017 14:12:25 +0100

> The stmmac driver have two methods for registers dumps: via ethtool and
> at init (if NETIF_MSG_HW is enabled).
> 
> It is better to keep only one method, ethtool, since the other was ugly.
> 
> This patch convert all dump_regs() function from "printing regs" to
> "fill the reg_space used by ethtool".
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
