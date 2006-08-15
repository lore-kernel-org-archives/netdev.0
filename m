From: David Miller <davem@davemloft.net>
Subject: Re: [patch 02/13] lockdep: annotate __icmpv6_socket
Date: Tue, 15 Aug 2006 00:09:42 -0700 (PDT)
Message-ID: <20060815.000942.32095273.davem@davemloft.net>
References: <200608150603.k7F63b6P012927@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mingo@elte.hu, arjan@linux.intel.com,
	herbert@gondor.apana.org.au, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19124
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965223AbWHOHJm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:09:42 -0400
To: akpm@osdl.org
In-Reply-To: <200608150603.k7F63b6P012927@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Mon, 14 Aug 2006 23:03:37 -0700

> From: Ingo Molnar <mingo@elte.hu>
> 
> Split off __icmpv6_socket's sk->sk_dst_lock class, because it gets used
> from softirqs, which is safe for __icmpv6_sockets (because they never get
> directly used via userspace syscalls), but unsafe for normal sockets.
> 
> Has no effect on non-lockdep kernels.
> 
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Arjan van de Ven <arjan@linux.intel.com>
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, I'll push this into 2.6.18
