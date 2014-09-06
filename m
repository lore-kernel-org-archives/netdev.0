From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cnic : Cleanup CONFIG_IPV6 & VLAN check
Date: Fri, 05 Sep 2014 20:47:33 -0700 (PDT)
Message-ID: <20140905.204733.1704763241808510916.davem@davemloft.net>
References: <1409875977-31584-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jitendra.kalsaria@qlogic.com,
	mchan@broadcom.com, eddie.wai@broadcom.com, randy.dunlap@oracle.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbaIFECn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 00:02:43 -0400
In-Reply-To: <1409875977-31584-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Thu,  4 Sep 2014 17:12:57 -0700

> The cnic module needs to ensure that if ipv6 support is compiled as a module,
> then the cnic module cannot be compiled as built-in as it depends on ipv6.
> Made this check cleaner via Kconfig
> 
> Use simpler IS_ENABLED for CONFIG_VLAN_8021Q check
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

Applied, thanks.
