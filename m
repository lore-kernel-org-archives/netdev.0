From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix PTP dependencies: explicitly select all the
 possible dependencies.
Date: Sun, 07 Oct 2012 14:54:32 -0400 (EDT)
Message-ID: <20121007.145432.1141528829169465290.davem@davemloft.net>
References: <50706885.1030908@linux.intel.com>
	<20121006.171748.734171045678392820.davem@davemloft.net>
	<50718E45.1070706@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: haicheng.li@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753814Ab2JGSyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 14:54:33 -0400
In-Reply-To: <50718E45.1070706@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haicheng Li <haicheng.li@linux.intel.com>
Date: Sun, 07 Oct 2012 22:14:29 +0800


Use "pch_gbe: " as the prefix in your patch Subject line,
also:

> @@ -26,6 +26,9 @@ if PCH_GBE
>  config PCH_PTP
>  	bool "PCH PTP clock support"
>  	default n
> +	depends on EXPERIMENTAL
> +	select PPS
> +	select PTP_1588_CLOCK

This patch is corrupted by your email client.

DO NOT resend this patch without first emailing it to yourself
and verifying that you can in fact apply what you receive in
the email cleanly.
