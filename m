From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: nhs: fix 32-bit build warning
Date: Thu, 08 Oct 2015 04:55:11 -0700 (PDT)
Message-ID: <20151008.045511.183579883465246367.davem@davemloft.net>
References: <8581924.9CPedieySC@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, huangdaode@hisilicon.com,
	liguozhu@huawei.com, Yisen.Zhuang@huawei.com
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986AbbJHLjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 07:39:23 -0400
In-Reply-To: <8581924.9CPedieySC@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 06 Oct 2015 23:53:57 +0200

> The recently added hns driver causes a build warning in ARM
> allmodconfig builds:
> 
> drivers/net/ethernet/hisilicon/hns/hnae.c: In function 'handles_show':
> drivers/net/ethernet/hisilicon/hns/hnae.c:452:13: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
>           j, (u64)h->qs[i]->io_base);
>              ^
> 
> This removes the pointless cast and prints the pointer address using
> the "%p" format string in all three locations.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied with subject typo fixed, thanks.
