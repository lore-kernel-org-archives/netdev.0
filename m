From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: ipv6_addr_type() doesn't know about RFC4193
 addresses
Date: Wed, 25 Jul 2007 17:12:03 -0700 (PDT)
Message-ID: <20070725.171203.102545287.davem@davemloft.net>
References: <18087.57717.495366.413571@zeus.sw.starentnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	sakkiped@starentnetworks.com
To: djohnson+linux-kernel@sw.starentnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41764
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751608AbXGZAME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 20:12:04 -0400
In-Reply-To: <18087.57717.495366.413571@zeus.sw.starentnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
Date: Wed, 25 Jul 2007 19:49:09 -0400

> 
> ipv6_addr_type() doesn't check for 'Unique Local IPv6 Unicast
> Addresses' (RFC4193) and returns IPV6_ADDR_RESERVED for that range.
> 
> SCTP uses this function and will fail bind() and connect() calls that
> use RFC4193 addresses, SCTP will also ignore inbound connections from
> RFC4193 addresses if listening on IPV6_ADDR_ANY.
> 
> There may be other users of ipv6_addr_type() that could also have
> problems.

Contrarily, there may be ipv6_addr_type() call sites that really
do want to reject rfc4193 addresses.
