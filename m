From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/7] net: use platform_{get,set}_drvdata()
Date: Thu, 15 Aug 2013 15:23:59 -0700 (PDT)
Message-ID: <20130815.152359.920302339053249583.davem@davemloft.net>
References: <520CD11D.8010202@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lizefan@huawei.com, leoli@freescale.com,
	linuxppc-dev@lists.ozlabs.org, pantelis.antoniou@gmail.com,
	vbordug@ru.mvista.com, gregkh@linuxfoundation.org,
	jg1.han@samsung.com, sergei.shtylyov@cogentembedded.com
To: clbchenlibo.chen@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915Ab3HOWYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 18:24:00 -0400
In-Reply-To: <520CD11D.8010202@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Libo Chen <clbchenlibo.chen@huawei.com>
Date: Thu, 15 Aug 2013 21:01:17 +0800

> Use the wrapper functions for getting and setting the driver data using
> platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
> so we can directly pass a struct platform_device.
> 
> changelog v3:
> 	remove modify about dev_set_drvdata()
> changelog v2:
> 	this version add modify record about dev_set_drvdata().

Series applied.
