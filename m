From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qlcnic: Convert vmalloc/memset to kcalloc
Date: Mon, 13 Jan 2014 11:17:50 -0800 (PST)
Message-ID: <20140113.111750.1356628971361206390.davem@davemloft.net>
References: <1389249745.24222.20.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jitendra.kalsaria@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbaAMTRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 14:17:51 -0500
In-Reply-To: <1389249745.24222.20.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 08 Jan 2014 22:42:25 -0800

> vmalloc is a limited resource.  Don't use it unnecessarily.
> 
> It seems this allocation should work with kcalloc.
> 
> Remove unnecessary memset(,0,) of buf as it's completely
> overwritten as the previously only unset field in
> struct qlcnic_pci_func_cfg is now set to 0.
> 
> Use kfree instead of vfree.
> Use ETH_ALEN instead of 6.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
