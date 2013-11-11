From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xtsonic: add missing platform_set_drvdata() in
 xtsonic_probe()
Date: Mon, 11 Nov 2013 14:02:45 -0500 (EST)
Message-ID: <20131111.140245.21767088027154743.davem@davemloft.net>
References: <CAPgLHd8pm_g=PCNJXo2iEvuWykyP_ewnsfS9FQ2qmQwRGjVuCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wfp5p@virginia.edu, gregkh@linuxfoundation.org,
	michael.opdenacker@free-electrons.com, joe@perches.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754916Ab3KKTCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 14:02:47 -0500
In-Reply-To: <CAPgLHd8pm_g=PCNJXo2iEvuWykyP_ewnsfS9FQ2qmQwRGjVuCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 11 Nov 2013 14:17:17 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Add missing platform_set_drvdata() in xtsonic_probe(), otherwise
> calling platform_get_drvdata() in xtsonic_device_remove() may
> returns NULL.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
