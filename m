From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v2] net: consolidate netif_needs_gso()
 checks
Date: Sat, 27 Feb 2010 08:17:09 -0800 (PST)
Message-ID: <20100227.081709.10203578.davem@davemloft.net>
References: <20100227001954.32474.62766.stgit@localhost.localdomain>
	<20100227.032725.158512690.davem@davemloft.net>
	<20100227155245.GB3176@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, john.r.fastabend@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34162
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S968514Ab0B0QQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 11:16:53 -0500
In-Reply-To: <20100227155245.GB3176@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 27 Feb 2010 23:52:45 +0800

> I just did a grep on net/sched and couldn't see anything obvious
> that uses transport_header.

I think skb_checksum_help() would be such a use and I
see a reference in net/sched/sch_netem.c

