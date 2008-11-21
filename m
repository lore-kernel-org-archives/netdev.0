From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] netdev: add more functions to netdevice ops
Date: Thu, 20 Nov 2008 20:27:44 -0800 (PST)
Message-ID: <20081120.202744.263799534.davem@davemloft.net>
References: <20081120175913.943543638@vyatta.com>
	<20081120175933.601338012@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48123
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751539AbYKUE1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 23:27:44 -0500
In-Reply-To: <20081120175933.601338012@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 20 Nov 2008 09:59:14 -0800

> This patch moves neigh_setup and hard_start_xmit into the network device ops
> structure. For bisection, fix all the previously converted drivers as well.
> Bonding driver took the biggest hit on this.
> 
> Added a prefetch of the hard_start_xmit in the fast path to try and reduce
> any impact this would have.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
