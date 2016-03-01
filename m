From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethtool.h: define DIV_ROUND_UP for userland
Date: Tue, 01 Mar 2016 11:42:32 -0500 (EST)
Message-ID: <20160301.114232.138387157898713379.davem@davemloft.net>
References: <1456845641-6985-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
	kan.liang@intel.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbcCAQmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 11:42:33 -0500
In-Reply-To: <1456845641-6985-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue,  1 Mar 2016 16:20:41 +0100

> DIV_ROUND_UP and is defined in linux/kernel.h only for the kernel. INT_MAX
> needs limits.h in userland.

It is wrong to provide a definition of this in the user visible global
namespace.
