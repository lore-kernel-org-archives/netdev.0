From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v1] 8021q: fix vlan device to inherit the
 unicast filtering capability flag
Date: Fri, 30 Nov 2012 12:09:03 -0500 (EST)
Message-ID: <20121130.120903.2063684278156777942.davem@davemloft.net>
References: <20121128234520.6615.41220.stg.yi.zou@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@open-fcoe.org
To: yi.zou@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757310Ab2K3RJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 12:09:05 -0500
In-Reply-To: <20121128234520.6615.41220.stg.yi.zou@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>
Date: Wed, 28 Nov 2012 15:45:24 -0800

> This bug is observed on running FCoE over a VLAN device associated w/
> a real device that has IFF_UNICAST_FLT set since FCoE would add unicast
> address such as FLOGI MAC to the VLAN interface that FCoE is on. Since
> currently, VLAN device is not inheriting the IFF_UNICAST_FLT flag from the
> parent real device even though the real device is capable of doing unicast
> filtering. This forces the VLAN device and its real device go to promiscuous
> mode unnecessarily even the added address is actually being added to the
> available unicast filter table in real device.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>

Applied.
