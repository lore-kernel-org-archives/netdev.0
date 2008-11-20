From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next]netdevice hamradio: Convert directly reference
 of netdev->priv
Date: Thu, 20 Nov 2008 01:02:12 -0800 (PST)
Message-ID: <20081120.010212.100990737.davem@davemloft.net>
References: <49223E7D.8090308@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46427
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752145AbYKTJCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 04:02:12 -0500
In-Reply-To: <49223E7D.8090308@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Tue, 18 Nov 2008 12:03:09 +0800

> Since all the memory, which pointed by netdev->priv, are allocated in advance instead of
> by alloc_netdev().
> Use netdev->ml_priv to point to those memory.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.
