From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/5] xfrm: Convert xfrm_addr_cmp() to boolean
 xfrm_addr_equal().
Date: Tue, 29 Jan 2013 22:56:14 -0500 (EST)
Message-ID: <20130129.225614.2216432655261969063.davem@davemloft.net>
References: <510851D2.8080000@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427Ab3A3D4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 22:56:15 -0500
In-Reply-To: <510851D2.8080000@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Wed, 30 Jan 2013 07:48:50 +0900

> All users of xfrm_addr_cmp() use its result as boolean.
> Introduce xfrm_addr_equal() (which is equal to !xfrm_addr_cmp())
> and convert all users.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
