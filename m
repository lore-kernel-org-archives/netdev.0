From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Wed, 03 Jun 2009 21:56:21 -0700 (PDT)
Message-ID: <20090603.215621.136203134.davem@davemloft.net>
References: <200906041324.59118.rusty@rustcorp.com.au>
	<20090603.210054.18839960.davem@davemloft.net>
	<4A275380.1050601@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, divy@chelsio.com,
	rolandd@cisco.com, xemul@openvz.org, dcbw@redhat.com,
	libertas-dev@lists.infradead.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37627
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751924AbZFDE4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 00:56:20 -0400
In-Reply-To: <4A275380.1050601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Jun 2009 06:54:24 +0200

> We also can avoid the sock_put()/sock_hold() pair for each tx packet,
> to only touch sk_wmem_alloc (with appropriate atomic_sub_return() in sock_wfree()
> and atomic_dec_test in sk_free
> 
> We could initialize sk->sk_wmem_alloc to one instead of 0, so that
> sock_wfree() could just synchronize itself with sk_free()

Excellent idea Eric.

> Patch will follow after some testing

I look forward to it :-)
