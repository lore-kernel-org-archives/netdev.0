From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: fix race between cleanup and add/delete address
Date: Thu, 04 Mar 2010 00:40:19 -0800 (PST)
Message-ID: <20100304.004019.158435620.davem@davemloft.net>
References: <20100303.011605.225992271.davem@davemloft.net>
	<20100303101449.2ae6a4ca@nehalam>
	<20100303101959.481d76fe@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36151
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753940Ab0CDIkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 03:40:00 -0500
In-Reply-To: <20100303101959.481d76fe@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 3 Mar 2010 10:19:59 -0800

> This solves a potential race problem during the cleanup process.
> The issue is that addrconf_ifdown() needs to traverse address list,
> but then drop lock to call the notifier. The version in -next
> could get confused if add/delete happened during this window.
> Original code (2.6.32 and earlier) was okay because all addresses
> were always deleted.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
