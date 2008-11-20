From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netdevice ni65: Convert directly reference of
 netdev->priv
Date: Thu, 20 Nov 2008 04:25:12 -0800 (PST)
Message-ID: <20081120.042512.147151638.davem@davemloft.net>
References: <49252AD8.4030306@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38630
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752543AbYKTMZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 07:25:12 -0500
In-Reply-To: <49252AD8.4030306@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 20 Nov 2008 17:16:08 +0800

> This patch is to kill directly reference of netdev->priv too.
> Because the private data needs special memory: lower 16MB DMA.
> alloc_etherdev() can do this work.
> So we can't use netdev->priv to point to netdev's private data.
> Use netdev->ml_priv instead.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.
