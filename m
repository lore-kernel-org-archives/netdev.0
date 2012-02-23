From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netdev/phy/icplus: Correct broken phy_init code
Date: Thu, 23 Feb 2012 17:14:39 -0500 (EST)
Message-ID: <20120223.171439.490391422998418894.davem@davemloft.net>
References: <1329895498-5810-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.mckay@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575Ab2BWWOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 17:14:46 -0500
In-Reply-To: <1329895498-5810-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 22 Feb 2012 08:24:57 +0100

> From: David McKay <david.mckay@st.com>
> 
> The code for ip1001_config_init() was totally broken if you were not
> using RGMII. Instead of returning an error code or zero it actually
> returned the value in the IP1001_SPEC_CTRL_STATUS_2 register. It was
> also trying to set the IP1001_APS_ON bit , but never actually wrote
> back the register.
> 
> The error checking was also incorrect in both this function and the
> reset function, so this patch fixes that up in a consistent fashion.
> 
> Signed-off-by: David McKay <david.mckay@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
