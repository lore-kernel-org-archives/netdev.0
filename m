From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] rcu_assign_pointer: null check fix
Date: Tue, 12 Feb 2008 17:27:26 -0800 (PST)
Message-ID: <20080212.172726.94705976.davem@davemloft.net>
References: <20080213005042.150212716@vyatta.com>
	<20080213005122.653836965@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernle.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49175
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757400AbYBMB0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 20:26:54 -0500
In-Reply-To: <20080213005122.653836965@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 12 Feb 2008 16:50:43 -0800

> Goofed on last change, should avoid barrier only on rcu_assign_pointer(p, NULL)
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Like the original change this needs to be merged upstream outside of
the networking tree, sorry.
