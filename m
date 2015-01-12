From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/6] irda: Use ktime_t instead of timeval
Date: Sun, 11 Jan 2015 21:44:14 -0500 (EST)
Message-ID: <20150111.214414.1072231038443972770.davem@davemloft.net>
References: <driver-irda-v2>
	<1420689692-8760-1-git-send-email-zhang.chunyan@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, arnd@arndb.de, zhang.lyra@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: zhang.chunyan@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43065 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbbALCoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2015 21:44:19 -0500
In-Reply-To: <1420689692-8760-1-git-send-email-zhang.chunyan@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chunyan Zhang <zhang.chunyan@linaro.org>
Date: Thu,  8 Jan 2015 12:01:26 +0800

> This patch-set removed all uses of timeval and used ktime_t instead if
> needed, since 32-bit time types will break in the year 2038.
> 
> This patch-set also used the ktime_xxx functions accordingly.
> e.g.
> * Used ktime_get to get the current time instead of do_gettimeofday.
> * And, used ktime_us_delta to get the elapsed time directly.

Applied to net-next, thanks.
