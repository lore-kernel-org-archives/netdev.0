From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: udp: check sk->sk_no_check when sending udpv6
 packet
Date: Sun, 19 Jan 2014 19:54:01 -0800 (PST)
Message-ID: <20140119.195401.51911668875807486.davem@davemloft.net>
References: <52DC9D25.9070809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41051 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbaATDyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 22:54:02 -0500
In-Reply-To: <52DC9D25.9070809@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Mon, 20 Jan 2014 11:51:01 +0800

> According to the user's intention, if SO_NO_CHECK option is
> set to true, the udpv6 packet should be out with no checksum.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

This is intentionally not supported in ipv6.
