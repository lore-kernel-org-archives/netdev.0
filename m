From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] ipvlan: inherit MTU from master device
Date: Thu, 04 Feb 2016 19:22:21 -0500 (EST)
Message-ID: <20160204.192221.2162532613179382427.davem@davemloft.net>
References: <1453966408-16343-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, edumazet@google.com, thockin@google.com,
	netdev@vger.kernel.org, eric.dumazet@gmail.com, thockins@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753953AbcBEAW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 19:22:29 -0500
In-Reply-To: <1453966408-16343-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Wed, 27 Jan 2016 23:33:28 -0800

> From: Mahesh Bandewar <maheshb@google.com>
> 
> When we create IPvlan slave; we use ether_setup() and that
> sets up default MTU to 1500 while the master device may have
> lower / different MTU. Any subsequent changes to the masters'
> MTU are reflected into the slaves' MTU setting. However if those
> don't happen (most likely scenario), the slaves' MTU stays at
> 1500 which could be bad.
> 
> This change adds code to inherit MTU from the master device
> instead of using the default value during the link initialization
> phase.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied, thanks.
