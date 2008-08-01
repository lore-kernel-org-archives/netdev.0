From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]&[Question] netdevice: Use netdev_priv()
Date: Fri, 01 Aug 2008 03:08:34 -0700 (PDT)
Message-ID: <20080801.030834.245436720.davem@davemloft.net>
References: <4892DC57.2060101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43236
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751387AbYHAKIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 06:08:34 -0400
In-Reply-To: <4892DC57.2060101@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 01 Aug 2008 17:50:15 +0800

> That make me think, what the use of netdev->priv?
> We have netdev_priv() and use it flexibly. Why don't kill netdev->priv?

Way too many old drivers still reference netdev->priv directly.

Once we convert all of them to netdev_priv(), yes we can kill
netdev->priv
