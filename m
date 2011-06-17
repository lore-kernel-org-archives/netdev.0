From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet_diag: fix inet_diag_bc_audit()
Date: Fri, 17 Jun 2011 16:26:27 -0400 (EDT)
Message-ID: <20110617.162627.2256444264676322354.davem@davemloft.net>
References: <1306942849.3150.10.camel@dan>
	<BANLkTin9fqYSxq4ne5hV_ri-zKeMZ9mE_g@mail.gmail.com>
	<1308341990.3539.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eugeneteo@kernel.sg, drosenberg@vsecurity.com,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org, security@kernel.org,
	acme@redhat.com, shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50397 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755435Ab1FQU1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 16:27:11 -0400
In-Reply-To: <1308341990.3539.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 Jun 2011 22:19:50 +0200

> [PATCH] inet_diag: fix inet_diag_bc_audit()
> 
> A malicious user or buggy application can inject code and trigger an
> infinite loop in inet_diag_bc_audit()
> 
> Also make sure each instruction is aligned on 4 bytes boundary, to avoid
> unaligned accesses.
> 
> Reported-by: Dan Rosenberg <drosenberg@vsecurity.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks!
