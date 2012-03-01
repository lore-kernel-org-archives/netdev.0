From: David Miller <davem@davemloft.net>
Subject: Re: [patch] pch_gbe: memory corruption calling
 pch_gbe_validate_option()
Date: Thu, 01 Mar 2012 17:24:02 -0500 (EST)
Message-ID: <20120301.172402.1035366198258013912.davem@davemloft.net>
References: <20120301071708.GB6959@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: masa-korg@dsn.okisemi.com, paul.gortmaker@windriver.com,
	jeffrey.t.kirsher@intel.com, mirq-linux@rere.qmqm.pl,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965173Ab2CAWZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 17:25:12 -0500
In-Reply-To: <20120301071708.GB6959@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 1 Mar 2012 10:17:08 +0300

> pch_gbe_validate_option() modifies 32 bits of memory but we pass
> &hw->phy.autoneg_advertised which only has 16 bits and &hw->mac.fc
> which only has 8 bits.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
