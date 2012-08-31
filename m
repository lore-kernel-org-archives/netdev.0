From: David Miller <davem@davemloft.net>
Subject: Re: [Stlinux-devel] [PATCH linux-stm 3/4] net/stmmac: Remove
 bus_id from mdio platform data.
Date: Fri, 31 Aug 2012 16:13:00 -0400 (EDT)
Message-ID: <20120831.161300.738499710469949166.davem@davemloft.net>
References: <1346341843-20169-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com
To: srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53177 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755007Ab2HaUNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 16:13:02 -0400
In-Reply-To: <1346341843-20169-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Date: Thu, 30 Aug 2012 16:50:43 +0100

> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> 
> This patch removes bus_id from mdio platform data, The reason to remove
> bus_id is, stmmac mdio bus_id is always same as stmmac bus-id, so there
> is no point in passing this in different variable.
> Also stmmac ethernet driver connects to phy with bus_id passed its
> platform data.
> So, having single bus-id is much simpler.
> 
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>

Applied.
