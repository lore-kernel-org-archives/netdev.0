From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] stmmac: add MMC supports exported via debugfs.
Date: Fri, 26 Aug 2011 12:12:22 -0400 (EDT)
Message-ID: <20110826.121222.1125604441814245954.davem@davemloft.net>
References: <1314259229-13767-1-git-send-email-peppe.cavallaro@st.com>
	<1314259229-13767-4-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38077 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754812Ab1HZQM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:12:28 -0400
In-Reply-To: <1314259229-13767-4-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 25 Aug 2011 10:00:23 +0200

> This patch adds the MMC management counters support.
> MMC module is an extension of the register address
> space and all the hardware counters can be accessed
> via debugfs.
> Below an example of the output:

This is not the appropriate way to expose internal chip counters.

Please use ethtool statistics for this.
