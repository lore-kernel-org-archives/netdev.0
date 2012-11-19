From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3.7.0-rc4] of/net/mdio-gpio: Fix pdev->id issue when
 using devicetrees.
Date: Mon, 19 Nov 2012 18:58:08 -0500 (EST)
Message-ID: <20121119.185808.1849458112621237233.davem@davemloft.net>
References: <1352816773-17837-1-git-send-email-srinivas.kandagatla@st.com>
	<1353062039-31336-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org
To: srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34665 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753607Ab2KSX6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 18:58:09 -0500
In-Reply-To: <1353062039-31336-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Date: Fri, 16 Nov 2012 10:33:59 +0000

> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> 
> When the mdio-gpio driver is probed via device trees, the platform
> device id is set as -1, However the pdev->id is re-used as bus-id for
> while creating mdio gpio bus.
> So
> For device tree case the mdio-gpio bus name appears as "gpio-ffffffff"
> where as
> for non-device tree case the bus name appears as "gpio-<bus-num>"
> 
> Which means the bus_id is fixed in device tree case, so we can't have
> two mdio gpio buses via device trees. Assigning a logical bus number
> via device tree solves the problem and the bus name is much consistent
> with non-device tree bus name.
> 
> Without this patch
> 1. we can't support two mdio-gpio buses via device trees.
> 2. we should always pass gpio-ffffffff as bus name to phy_connect, very
> different to non-device tree bus name.
> 
> So, setting up the bus_id via aliases from device tree is the right
> solution and other drivers do similar thing.
> 
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>

Applied, thank you.
