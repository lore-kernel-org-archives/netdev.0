From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 0/5] amd-xgbe: AMD 10Gb Ethernet driver
Date: Wed, 04 Jun 2014 14:36:05 -0700 (PDT)
Message-ID: <20140604.143605.960519678688904189.davem@davemloft.net>
References: <20140604161130.6242.57741.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcm@redhat.com
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37068 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbaFDVgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 17:36:08 -0400
In-Reply-To: <20140604161130.6242.57741.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Wed, 4 Jun 2014 11:11:31 -0500

> The following series implements support for the new AMD 10Gb Ethernet
> driver (amd-xgbe).  It includes the 10Gb Ethernet driver as well as
> a 10Gb Ethernet PHY driver.
> 
> This patch series is based on net-next.
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

Series applied, thanks.
