From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: Allocate unique metrics for icmp6
 packets to prevent tainting dst metrics
Date: Fri, 16 Mar 2012 23:02:45 -0700 (PDT)
Message-ID: <20120316.230245.1004014834159539357.davem@davemloft.net>
References: <4F620DC5.7080607@network-box.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nick.jones@network-box.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826Ab2CQGCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 02:02:52 -0400
In-Reply-To: <4F620DC5.7080607@network-box.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Jones <nick.jones@network-box.com>
Date: Thu, 15 Mar 2012 23:41:57 +0800

> +	u32 *metrics = kzalloc(sizeof(u32) * RTAX_MAX, GFP_ATOMIC);

Please do not declare local variables in the middle of a function's
statements.  Put it at the top of the basic block where it belongs.
