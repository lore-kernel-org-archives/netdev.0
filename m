From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] be2net: patch set
Date: Sat, 13 Sep 2014 17:12:43 -0400 (EDT)
Message-ID: <20140913.171243.1325107254064998995.davem@davemloft.net>
References: <1410523761-1744-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38168 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118AbaIMVMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 17:12:44 -0400
In-Reply-To: <1410523761-1744-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Fri, 12 Sep 2014 17:39:13 +0530

> Patch 1 fixes some minor issues with log messages in be2net.
> 
> Patch 2 replaces strcpy() calls with strlcpy() to avoid possible buffer
> overflow.
> 
> Patch 3 improves the RX buffer posting scheme for jumbo frames.
> 
> Patch 4 replaces the use of v0 of SET_FLOW_CONTROL cmd with v1 to receive
> a definitive completion status from FW.
> 
> Patch 5 adds support for ethtool "-m" ethtool option.
> 
> Patch 6 fixes port-type reporting via ethtool get_settings for QSFP/SFP+
> interfaces.
> 
> Patch 7 fixes the usage of MODIFY_EQD FW cmd to target a max of 8 EQs on
> Lancer chip. 
> 
> Patch 8 enables PCIe error reporting even for VFs.
> 
> Pls consider applying this patch set to net-next. Thanks.

Series applied, thanks.
