From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/7] net: use platform_{get,set}_drvdata()
Date: Tue, 20 Aug 2013 17:19:07 -0700 (PDT)
Message-ID: <20130820.171907.865197874462124999.davem@davemloft.net>
References: <52120859.7060200@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lizefan@huawei.com, leoli@freescale.com,
	linuxppc-dev@lists.ozlabs.org, pantelis.antoniou@gmail.com,
	vbordug@ru.mvista.com, gregkh@linuxfoundation.org,
	jg1.han@samsung.com, sergei.shtylyov@cogentembedded.com
To: clbchenlibo.chen@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411Ab3HUATI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 20:19:08 -0400
In-Reply-To: <52120859.7060200@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Libo Chen <clbchenlibo.chen@huawei.com>
Date: Mon, 19 Aug 2013 19:58:17 +0800

> 
> Use the wrapper functions for getting and setting the driver data using
> platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
> so we can directly pass a struct platform_device.
> 
> changelog v4:
> 	remove modify about happy_meal_pci_probe && happy_meal_pci_remove
> changelog v3:
> 	remove modify about dev_set_drvdata()
> changelog v2:
> 	this version add modify record about dev_set_drvdata().

Series applied.
