From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netdevice lance: Convert directly reference
 of netdev->priv
Date: Thu, 20 Nov 2008 04:06:06 -0800 (PST)
Message-ID: <20081120.040606.18444184.davem@davemloft.net>
References: <492375B9.8020807@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35181
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754198AbYKTMGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 07:06:06 -0500
In-Reply-To: <492375B9.8020807@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Wed, 19 Nov 2008 10:11:05 +0800

> This patch is to kill directly reference of netdev->priv too.
> Because the private data should be allocated in DMA area, alloc_etherdev()
> can't satisfy this needs.
> Use netdev->ml_priv to point to lance_private.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied, thanks.
