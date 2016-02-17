From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/9] amd-xgbe: AMD XGBE driver updates
 2016-02-12
Date: Wed, 17 Feb 2016 15:23:11 -0500 (EST)
Message-ID: <20160217.152311.777296063590514786.davem@davemloft.net>
References: <20160217174758.26246.15641.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56966 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030310AbcBQUXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 15:23:15 -0500
In-Reply-To: <20160217174758.26246.15641.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Wed, 17 Feb 2016 11:47:58 -0600

> The following updates and fixes are included in this driver update series:
> 
> - Disable VLAN filtering in promiscuous mode
> - Change from using napi_complete to napi_complete_done
> - Use __napi_schedule_irqoff when running in interrupt context
> - Verify ethtool speed setting is valid for the selected speedset
> - Enable PFC based on the pfc_en setting
> - Fix the mapping of priorities to traffic classes
> - Do traffic class setup when DCB nl callbacks are invoked
> - Check Rx queue fifos before stopping Rx queue DMA
> - Switch from disable_irq to masking interrupts for auto-negotiation
> 
> This patch series is based on net-next.
> 
> ---
> 
> Changes from v1:
> - Removed #ifndef and #define of CRCPOLY_LE as part of the patch to
>   disable VLAN filtering in promiscuous mode
> - Reworked changes to xgbe_setup_tc to resolve conflicts with commit
>   16e5cc647173 (net: rework setup_tc ndo op to consume general tc operand)

Series applied, thanks Tom.
