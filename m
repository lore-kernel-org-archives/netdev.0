From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix config requirements of IPv6
Date: Thu, 06 Sep 2007 13:49:04 -0700 (PDT)
Message-ID: <20070906.134904.59659883.davem@davemloft.net>
References: <20070906200151.GA28306@mail1.bwalle.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: bernhard@bwalle.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:53391
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756597AbXIFUtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 16:49:42 -0400
In-Reply-To: <20070906200151.GA28306@mail1.bwalle.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernhard Walle <bernhard@bwalle.de>
Date: Thu, 6 Sep 2007 22:01:52 +0200

> [PATCH] Fix config requirements of IPv6
> 
> net/ipv6/inet6_connection_sock.c in function __inet6_csk_dst_store() requires
> flow_cache_genid which is defined in net/core/flow.c which is compiled when
> CONFIG_XFRM is set.
> 
> This patch expresses that dependency.
> 
> 
> Signed-off-by: Bernhard Walle <bernhard@bwalle.de>

IPV6 should not require XFRM, a proper fix for this issue
was added to the net-2.6.24 tree earlier today already.
