From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: fix endian check warning in etherdevice.h
Date: Mon, 17 Aug 2015 12:16:05 -0700 (PDT)
Message-ID: <20150817.121605.400650271118838786.davem@davemloft.net>
References: <20150814013403.20350.45692.stgit@jbrandeb-hsm1.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152AbbHQTQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 15:16:06 -0400
In-Reply-To: <20150814013403.20350.45692.stgit@jbrandeb-hsm1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Thu, 13 Aug 2015 18:34:03 -0700

> Sparse builds have been warning for a really long time now
> that etherdevice.h has a conversion that is unsafe.
> 
>   include/linux/etherdevice.h:79:32: warning: restricted __be16 degrades to integer
> 
> This code change fixes the issue and generates the exact
> same assembly before/after (checked on x86_64)
> 
> Fixes: 2c722fe1c821 (etherdevice: Optimize a few is_<foo>_ether_addr functions)
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

Applied, thanks Jesse.
