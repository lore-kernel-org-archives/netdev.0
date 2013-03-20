From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] chelsio: use netdev_alloc_skb_ip_align
Date: Wed, 20 Mar 2013 15:25:00 -0400 (EDT)
Message-ID: <20130320.152500.1106042522992222843.davem@davemloft.net>
References: <20130320113024.00377b99@nehalam.linuxnetplumber.net>
	<1363804952.3333.29.camel@edumazet-glaptop>
	<20130320120241.19314ab6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756665Ab3CTTZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 15:25:03 -0400
In-Reply-To: <20130320120241.19314ab6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 20 Mar 2013 12:02:41 -0700

> Use netdev_alloc_sk_ip_align in the case where packet is copied.
> This handles case where NET_IP_ALIGN == 0 as well as adding required header
> padding.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks Stephen.
