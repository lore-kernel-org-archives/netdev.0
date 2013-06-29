From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/ptp/Kconfig: add "depends on HAS_IOMEM" for
 'PTP_1588_CLOCK_PCH'
Date: Fri, 28 Jun 2013 21:23:11 -0700 (PDT)
Message-ID: <20130628.212311.1348427834856668120.davem@davemloft.net>
References: <51CB8CB7.6010006@asianux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org, richard@nod.at,
	geert@linux-m68k.org
To: gang.chen@asianux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46162 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab3F2EXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 00:23:12 -0400
In-Reply-To: <51CB8CB7.6010006@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Gang <gang.chen@asianux.com>
Date: Thu, 27 Jun 2013 08:52:07 +0800

> @@ -73,6 +73,7 @@ config DP83640_PHY
>  config PTP_1588_CLOCK_PCH
>  	tristate "Intel PCH EG20T as PTP clock"
>  	depends on X86 || COMPILE_TEST

This "depends on X86 || COMPILE_TEST" does not exist in either 'net' or 'net-next'.
Please submit your patches against a clean checkout of the networking GIT tree,
rather than something else such as linux-next.

Thanks.
