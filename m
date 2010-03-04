From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/12] IPv6: addrconf dad timer unnecessary bh_disable
Date: Thu, 04 Mar 2010 00:39:56 -0800 (PST)
Message-ID: <20100304.003956.52175727.davem@davemloft.net>
References: <20100302233243.259794027@vyatta.com>
	<20100302234002.893332269@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36136
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754268Ab0CDIjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 03:39:37 -0500
In-Reply-To: <20100302234002.893332269@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 02 Mar 2010 15:32:44 -0800

> Timer code runs in bottom half, so there is no need for
> using _bh form of locking.  Also check if device is not ready
> to avoid race with address that is no longer active.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
