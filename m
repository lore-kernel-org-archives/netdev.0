From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macmace: add missing platform_set_drvdata() in
 mace_probe()
Date: Mon, 11 Nov 2013 14:02:38 -0500 (EST)
Message-ID: <20131111.140238.1927764495886700485.davem@davemloft.net>
References: <CAPgLHd8tvWttse-CzOcLeAfk0jySZLRhsJ2FCWsxiGaBHfBHMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wfp5p@virginia.edu, gregkh@linuxfoundation.org, joe@perches.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161Ab3KKTCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 14:02:41 -0500
In-Reply-To: <CAPgLHd8tvWttse-CzOcLeAfk0jySZLRhsJ2FCWsxiGaBHfBHMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 11 Nov 2013 14:16:16 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Add missing platform_set_drvdata() in mace_probe(), otherwise
> calling platform_get_drvdata() in mac_mace_device_remove() may
> returns NULL.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
