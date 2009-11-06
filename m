From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rose: device refcount leak
Date: Thu, 05 Nov 2009 21:08:18 -0800 (PST)
Message-ID: <20091105.210818.136976106.davem@davemloft.net>
References: <4AF1E4A9.7050404@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52495
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753476AbZKFFHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 00:07:52 -0500
In-Reply-To: <4AF1E4A9.7050404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Nov 2009 21:31:37 +0100

> While hunting dev_put() for net-next-2.6, I found a device refcount
> leak in ROSE, ioctl(SIOCADDRT) error path.
> 
> Fix is to not touch device refcount, as we hold RTNL
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-2.6, thanks.
