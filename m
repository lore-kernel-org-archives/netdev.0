From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.7.0-rc4] of/net/mdio-gpio: Fix pdev->id issue when
 using devicetrees.
Date: Wed, 14 Nov 2012 18:59:40 -0500 (EST)
Message-ID: <20121114.185940.648295821386414260.davem@davemloft.net>
References: <1352816773-17837-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org
To: srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37014 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755412Ab2KNX7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 18:59:42 -0500
In-Reply-To: <1352816773-17837-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Date: Tue, 13 Nov 2012 14:26:13 +0000

> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> 
> When the mdio-gpio driver is probed via device trees, the platform
> device id is set as -1, However the id is re-used in the code while
> creating an mdio bus.
> So, setting up the id via aliases from device tree is a sensible
> solution to fix this issue.
> 
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This seems rather pointless unless you also update every single device
tree out there.

Also you need to describe what are the ramifications of this problem
otherwise it is impossible to figure out how serious this change is.

Does it prevent probing?  Does it cause a crash?

Basically, what I'm saying is that this is a very poor submission and
you need to substantially improve it and communicate better.

If the problem is basically benign, then you should target this change
to net-next instead of the net tree, along with the necessary dt file
updates.

Thanks.
