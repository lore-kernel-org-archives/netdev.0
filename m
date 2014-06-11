From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: xen-netback: include linux/vmalloc.h again
Date: Wed, 11 Jun 2014 15:19:49 -0700 (PDT)
Message-ID: <20140611.151949.426688931837568113.davem@davemloft.net>
References: <5508988.K5Wec8A6hA@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wei.liu2@citrix.com,
	andrew.bennieston@citrix.com, xen-devel@lists.xenproject.org,
	jwboyer@fedoraproject.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbaFKWTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:19:50 -0400
In-Reply-To: <5508988.K5Wec8A6hA@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 10 Jun 2014 10:34:36 +0200

> commit e9ce7cb6b107 ("xen-netback: Factor queue-specific data into
> queue struct") added a use of vzalloc/vfree to interface.c, but
> removed the #include <linux/vmalloc.h> statement at the same time,
> which causes this build error:
> 
> drivers/net/xen-netback/interface.c: In function 'xenvif_free':
> drivers/net/xen-netback/interface.c:754:2: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
>   vfree(vif->queues);
>   ^
> cc1: some warnings being treated as errors
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied to net-next, thanks.
