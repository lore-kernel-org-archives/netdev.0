From: David Miller <davem@davemloft.net>
Subject: Re: linux kernel 2.6.18-20 bug: rcu_read_unlock in __sock_create
Date: Wed, 15 Aug 2007 14:46:28 -0700 (PDT)
Message-ID: <20070815.144628.104052147.davem@davemloft.net>
References: <af57f1ac0708141130v729fa636k3150673809ec20a8@mail.gmail.com>
	<E1ILEJr-0005Fl-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 123.oleg@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45840
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755443AbXHOVqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 17:46:35 -0400
In-Reply-To: <E1ILEJr-0005Fl-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 15 Aug 2007 16:33:35 +0800

> [NET]: Fix unbalanced rcu_read_unlock in __sock_create
> 
> The recent RCU work created an unbalanced rcu_read_unlock
> in __sock_create.  This patch fixes that.  Reported by
> oleg 123.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Patch applied, thanks Herbert.
