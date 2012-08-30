From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.6.0-rc3 2/2] of/mdio-gpio: Simplify the way device
 tree support is implemented.
Date: Thu, 30 Aug 2012 12:38:37 -0400 (EDT)
Message-ID: <20120830.123837.1714554699135488968.davem@davemloft.net>
References: <1345809557-27727-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, laurentp@cse-semaphore.com,
	devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca
To: srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37626 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810Ab2H3Qij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 12:38:39 -0400
In-Reply-To: <1345809557-27727-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Date: Fri, 24 Aug 2012 12:59:17 +0100

> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> 
> This patch cleans up the way device tree support is added in mdio-gpio
> driver. I found lot of code duplication which is not necessary.
> Also strangely a new platform driver was also introduced for device tree
> support. All this forced me to do this cleanup patch.
> After this patch, the driver probe checks the of_node pointer to get the
> data from device tree.
> 
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>

Applied to net-next.
