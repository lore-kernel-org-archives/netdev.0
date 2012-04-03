From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.3.0 1/3] net:phy:bcm63xx: remove unnecessary code
Date: Tue, 03 Apr 2012 19:02:40 -0400 (EDT)
Message-ID: <20120403.190240.1551928087376678842.davem@davemloft.net>
References: <4F79D91A.2030403@st.com>
	<1333386157.15422.21.camel@joe2Laptop>
	<4F7AC7B5.3040301@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39368 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755687Ab2DCXCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 19:02:48 -0400
In-Reply-To: <4F7AC7B5.3040301@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Date: Tue, 03 Apr 2012 10:49:41 +0100

> Yes, I have audited all the drivers. none of them return positive values.
> In general, I think phy_write should return either 0 or an error code
> and *NOT* positive values.
> Any mdio bus driver returning positive values for phy_writes will break
> the phylib too.

I've applied all three patches to net-next, thanks.
