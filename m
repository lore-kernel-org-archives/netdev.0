From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] USB2NET: SR9800: use %zu for size_t
Date: Thu, 13 Feb 2014 18:47:55 -0500 (EST)
Message-ID: <20140213.184755.724709088901100312.davem@davemloft.net>
References: <000101cf2885$395755a0$ac0600e0$%han@samsung.com>
	<000101cf288a$9afc0800$d0f41800$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, liujunliang_ljl@163.com, joe@perches.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51545 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199AbaBMXr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 18:47:57 -0500
In-Reply-To: <000101cf288a$9afc0800$d0f41800$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Thu, 13 Feb 2014 16:09:58 +0900

> Use %zu for size_t in order to avoid the following build
> warning in printks.
> 
> drivers/net/usb/sr9800.c: In function 'sr9800_bind'
> drivers/net/usb/sr9800.c:826:2: warning: format '%ld' expects argument of type 'long int' but argument 5 has type 'size_t'
> [-Wformat]
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied, thanks.
