From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: use pre-defined macro in bond_mode_name
 instead of magic number 0
Date: Fri, 26 Jul 2013 13:53:30 -0700 (PDT)
Message-ID: <20130726.135330.232525167518786234.davem@davemloft.net>
References: <51EF79E6.9060309@gmail.com>
	<1374649819.18818.5.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shhuiw@gmail.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36857 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932768Ab3GZUxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 16:53:31 -0400
In-Reply-To: <1374649819.18818.5.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 24 Jul 2013 00:10:19 -0700

> Probably be simpler, less confusing, and more normal style
> to use a switch case.
> 
> 	switch (mode) {
> 	case BOND_MODE_ROUNDROBIN:
> 		return "load balancing (round-robin)";
> 	case BOND_MODE_ACTIVEBACKUP:
> 		return "fault-tolerance (active-backup)";
> 	case BOND_MODE_XOR:
> 		return "load balancing (xor)";
> 	case BOND_MODE_BROADCAST;
> 		return "fault-tolerance (broadcast)";
> 	case BOND_MODE_8023AD:
> 		return "IEEE 802.3ad Dynamic link aggregation";
> 	case BOND_MODE_TLB:
> 		return "transmit load balancing";
> 	case BOND_MODE_ALB:
> 		return "adaptive load balancing";
> 	default:
> 		return "unknown";
> 	}

I have to say that I do not prefer this approach.

I have a good idea what the compiler ends up outputting for the above,
and the "indexed table of strings" approach is much less code.
