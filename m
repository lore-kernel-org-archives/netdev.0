From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: remove duplicate neigh_ifdown
Date: Sat, 18 Dec 2010 22:02:17 -0800 (PST)
Message-ID: <20101218.220217.115939790.davem@davemloft.net>
References: <20101216175152.6767d0a7@nehalam>
	<20101216194254.0f7c7e7b@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34214
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751159Ab0LSGBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Dec 2010 01:01:48 -0500
In-Reply-To: <20101216194254.0f7c7e7b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 16 Dec 2010 19:42:54 -0800

> When device is being set to down, neigh_ifdown was being called
> twice. Once from addrconf notifier and once from ndisc notifier.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
