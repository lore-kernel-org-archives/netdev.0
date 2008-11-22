From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netdevice hdlc: Convert directly reference of
 netdev->priv
Date: Fri, 21 Nov 2008 16:34:44 -0800 (PST)
Message-ID: <20081121.163444.107452971.davem@davemloft.net>
References: <49267939.9090808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, khc@pm.waw.pl, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46594
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754007AbYKVAep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:34:45 -0500
In-Reply-To: <49267939.9090808@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 21 Nov 2008 17:02:49 +0800

> Krzysztof said that he will take this one, but not.
> I sent this to Dave again. :)
> 
> For killing directly reference of netdev->priv, use netdev->ml_priv to replace it.
> Because the private pvc data comes from add_pvc() and can't be allocated in
> alloc_netdev().
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> Acked-by: Krzysztof Halasa <khc@pm.waw.pl>

Applied.
