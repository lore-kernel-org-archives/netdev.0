From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/2] net:hns: annotate IO address space properly
Date: Sun, 13 Dec 2015 23:37:29 -0500 (EST)
Message-ID: <20151213.233729.714763727253422521.davem@davemloft.net>
References: <1449760990-111046-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, huangdaode@hisilicon.com,
	linux@rasmusvillemoes.dk
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201AbbLNEhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2015 23:37:31 -0500
In-Reply-To: <1449760990-111046-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Thu, 10 Dec 2015 17:23:09 +0200

> Mark address pointer with __iomem in the IO accessors.
> 
> Otherwise we will get a sparse complain like following
> 
> .../hns/hns_dsaf_reg.h:991:36: warning: incorrect type in argument 1 (different address spaces)
> .../hns/hns_dsaf_reg.h:991:36:    expected unsigned char [noderef] [usertype] <asn:2>*base
> .../hns/hns_dsaf_reg.h:991:36:    got void *base
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Applied.
