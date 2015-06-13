From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Fix Cavium Liquidio build related errors and
 warnings
Date: Fri, 12 Jun 2015 19:17:53 -0700 (PDT)
Message-ID: <20150612.191753.1337452083543935602.davem@davemloft.net>
References: <201506111433.eR8aCZeq%fengguang.wu@intel.com>
	<1434157910-5324-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbbFMCR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 22:17:56 -0400
In-Reply-To: <1434157910-5324-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Fri, 12 Jun 2015 18:11:50 -0700

> 1) Fixed following sparse warnings:
 ...
> 2) Fix build errors corresponding to vmalloc on linux-next 4.1.
> 3) Liquidio now supports 64 bit only, modified Kconfig accordingly.
> 4) Fix some code alignment issues based on kernel build warnings.
> 
> Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
> Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>

Applied, but I _seriously_ wish you didn't fix the readq/writeq stuff by
restricting the build of the driver to 64-bit.  That really kills build
test coverage.

Just provide an appropriate set of readq/writeq like other drivers do
by including either io-64-nonatomic-hi-lo.h or io-64-nonatomic-lo-hi.h

Thanks.
