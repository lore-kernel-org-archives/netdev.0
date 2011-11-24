From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Save nexthop address of LSRR/SSRR option to IPCB.
Date: Wed, 23 Nov 2011 19:41:13 -0500 (EST)
Message-ID: <20111123.194113.393282002365095979.davem@davemloft.net>
References: <4ECCBDD6.8080708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40496 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754208Ab1KXAlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 19:41:20 -0500
In-Reply-To: <4ECCBDD6.8080708@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Wed, 23 Nov 2011 17:33:10 +0800

> We can not update iph->daddr in ip_options_rcv_srr(), It is too early.
> When some exception ocurred later (eg. in ip_forward() when goto
> sr_failed) we need the ip header be identical to the original one as
> ICMP need it.
> 
> Add a field 'nexthop' in struct ip_options to save nexthop of LSRR
> or SSRR option.
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>

Applied, thanks.
