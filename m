From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix module refcount leak in kernel_accept()
Date: Thu, 18 Dec 2008 19:35:27 -0800 (PST)
Message-ID: <20081218.193527.239071578.davem@davemloft.net>
References: <494A23FE.6020305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52940
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752577AbYLSDfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 22:35:25 -0500
In-Reply-To: <494A23FE.6020305@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Thu, 18 Dec 2008 18:20:46 +0800

> The kernel_accept() does not hold the module refcount of newsock->ops->owner,
> so we need __module_get(newsock->ops->owner) code after call kernel_accept()
> by hand.
> In sunrpc, the module refcount is missing to hold. So this cause kernel panic.
> 
> Used following script to reproduct:
 ...
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Good fine, patch applied, thanks!
