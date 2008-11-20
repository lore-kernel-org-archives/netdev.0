From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3]netdevice: 82596: Convert netdev->priv to
 netdev_priv
Date: Thu, 20 Nov 2008 01:01:14 -0800 (PST)
Message-ID: <20081120.010114.116038785.davem@davemloft.net>
References: <20081117.012939.72047312.davem@davemloft.net>
	<492182C8.6060704@cn.fujitsu.com>
	<49223D25.9030006@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46421
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751926AbYKTJBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 04:01:14 -0500
In-Reply-To: <49223D25.9030006@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Tue, 18 Nov 2008 11:57:25 +0800

> 1. When alloc_etherdev(), no memory be allocated to netdev->priv.
> 2. And it's need to get a whole page for priv.
> 
> For these reasons, use netdev->ml_priv to point to the page is the
> best method to convert directly reference of netdev->priv.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied, thanks for all the hard work on this one ;-)
