From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix: Dereference pointer-value of
 sk_prot->memory_pressure
Date: Wed, 23 Oct 2013 16:15:39 -0400 (EDT)
Message-ID: <20131023.161539.1581232035449029458.davem@davemloft.net>
References: <20131023122543.GH5132@cpaasch-mac>
	<1382533364.7572.15.camel@edumazet-glaptop.roam.corp.google.com>
	<87r4bbiwyh.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, christoph.paasch@uclouvain.be,
	fengguang.wu@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40802 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513Ab3JWUPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 16:15:43 -0400
In-Reply-To: <87r4bbiwyh.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 23 Oct 2013 12:55:18 -0700

> From: Christoph Paasch <christoph.paasch@uclouvain.be>
> Date: Wed, 23 Oct 2013 12:49:21 -0700
> 
> 2e685cad57 (tcp_memcontrol: Kill struct tcp_memcontrol) falsly modified
> the access to memory_pressure of sk->sk_prot->memory_pressure. The patch
> did modify the memory_pressure-field of struct cg_proto, but not the one
> of struct proto.
> 
> So, the access to sk_prot->memory_pressure should not be changed.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied, but I replaced "Fix: " with "net: " in the commit header line.
