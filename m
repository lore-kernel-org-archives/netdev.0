From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next 0/5] amd-xgbe: AMD 10Gb Ethernet driver
Date: Thu, 05 Jun 2014 15:27:20 -0700 (PDT)
Message-ID: <20140605.152720.251044247420485501.davem@davemloft.net>
References: <20140605141454.19317.87165.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcm@redhat.com
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51570 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbaFEW1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 18:27:21 -0400
In-Reply-To: <20140605141454.19317.87165.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Thu, 5 Jun 2014 09:14:54 -0500

> The following series implements support for the new AMD 10Gb Ethernet
> driver (amd-xgbe).  It includes the 10Gb Ethernet driver as well as
> a 10Gb Ethernet PHY driver.
> 
> This patch series is based on net-next.
> 
> Changes in V3:
>   - Add OF dependency to the phylib driver configuration
> 
> Changes in V2:
>   - Add phy-mode to the amd-xgbe device bindings
>   - Obtain the phy-mode from the device tree
>   - Reference ethernet.txt device bindings for phy-handle and phy-mode
>   - Connect/disconnect to/from phy during probe/remove, instead of open/close
>   - Fixes for jumbo packet support / MTU changes
>   - Formatting changes for debug packet dump
>   - Free resources in the phylib driver remove function
>   - Proper NP NULL message during auto-negotiation

Series applied, thank you.
