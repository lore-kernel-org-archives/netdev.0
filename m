From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/12] IPv6: addrconf timer race
Date: Thu, 04 Mar 2010 00:40:00 -0800 (PST)
Message-ID: <20100304.004000.120457701.davem@davemloft.net>
References: <20100302233243.259794027@vyatta.com>
	<20100302234002.971992509@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36142
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754268Ab0CDIjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 03:39:42 -0500
In-Reply-To: <20100302234002.971992509@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 02 Mar 2010 15:32:45 -0800

> The Router Solicitation timer races with device state changes
> because it doesn't lock the device. Use local variable to avoid
> one repeated dereference.
> 
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
