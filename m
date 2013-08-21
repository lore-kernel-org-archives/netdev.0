From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] net: remove unnecessary dev_set_drvdata()
Date: Wed, 21 Aug 2013 12:27:18 -0700 (PDT)
Message-ID: <20130821.122718.211023142309177250.davem@davemloft.net>
References: <1377068737-48616-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	sergei.shtylyov@cogentembedded.com, jg1.han@samsung.com,
	leoli@freescale.com, gregkh@linuxfoundation.org,
	linuxppc-dev@lists.ozlabs.org, lizefan@huawei.com
To: libo.chen@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921Ab3HUT1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 15:27:20 -0400
In-Reply-To: <1377068737-48616-1-git-send-email-libo.chen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Libo Chen <libo.chen@huawei.com>
Date: Wed, 21 Aug 2013 15:05:37 +0800

> Unnecessary dev_set_drvdata() is removed, because the driver core
> clears the driver data to NULL after device_release or on probe failure.

Series applied, thanks.
