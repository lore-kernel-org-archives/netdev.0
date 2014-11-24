From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] ipvlan: Initial check-in of the IPVLAN
 driver.
Date: Mon, 24 Nov 2014 15:29:49 -0500 (EST)
Message-ID: <20141124.152949.2182493813217014128.davem@davemloft.net>
References: <1416812866-13401-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, maze@google.com,
	chavey@google.com, thockin@google.com, brandon.philips@coreos.com,
	xemul@parallels.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53080 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbaKXU3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 15:29:52 -0500
In-Reply-To: <1416812866-13401-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Sun, 23 Nov 2014 23:07:46 -0800

> This driver is very similar to the macvlan driver except that it
> uses L3 on the frame to determine the logical interface while
> functioning as packet dispatcher. It inherits L2 of the master
> device hence the packets on wire will have the same L2 for all
> the packets originating from all virtual devices off of the same
> master device.
> 
> This driver was developed keeping the namespace use-case in
> mind. Hence most of the examples given here take that as the
> base setup where main-device belongs to the default-ns and
> virtual devices are assigned to the additional namespaces.
 ...
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied, thanks.
