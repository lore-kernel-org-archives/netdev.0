From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] stmmac: fix oops on rmmod after assigning ip
 addr
Date: Thu, 16 Apr 2015 12:07:57 -0400 (EDT)
Message-ID: <20150416.120757.1014138571559447688.davem@davemloft.net>
References: <1429060066-9156-1-git-send-email-pure.logic@nexus-software.ie>
	<1429060066-9156-2-git-send-email-pure.logic@nexus-software.ie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	andriy.shevchenko@linux.intel.com, hock.leong.kweh@intel.com,
	boon.leong.ong@intel.com, dan.odonovan@emutex.com,
	linux-kernel@vger.kernel.org
To: pure.logic@nexus-software.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33361 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbbDPQH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 12:07:59 -0400
In-Reply-To: <1429060066-9156-2-git-send-email-pure.logic@nexus-software.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bryan O'Donoghue <pure.logic@nexus-software.ie>
Date: Wed, 15 Apr 2015 02:07:46 +0100

> An oops exists in the flow of stmmac_release().
> phy_ethtool_get_wol() depends on phydev->drv.
> phydev->drv will be null after stmmac_mdio_unreg() completes.
> 
> Steps to reproduce on Quark X1000:
> 
> 1. ifconfig eth0 192.168.0.1
> 2. rmmod stmmac_pci
> 
> To fix this stmmac_mdio_unreg() should be run after unregister_netdev().
> 
> Signed-off-by: Bryan O'Donoghue <pure.logic@nexus-software.ie>
> Reported-by: Dan O'Donovan <dan.odonovan@emutex.com>

This patch does not apply to the current tree, please respin.
