From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: sk_wmem_alloc initial value is one
Date: Wed, 17 Jun 2009 19:06:22 -0700 (PDT)
Message-ID: <20090617.190622.35929980.davem@davemloft.net>
References: <4A37FC93.7070403@gmail.com>
	<4A389031.1060902@gmail.com>
	<4A38D412.5000701@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48988
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752753AbZFRCGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 22:06:18 -0400
In-Reply-To: <4A38D412.5000701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 17 Jun 2009 13:31:30 +0200

> [PATCH] atm: sk_wmem_alloc initial value is one
> 
> commit 2b85a34e911bf483c27cfdd124aeb1605145dc80 
> (net: No more expensive sock_hold()/sock_put() on each tx)
> changed initial sk_wmem_alloc value.
> 
> This broke net/atm since this protocol assumed a null
> initial value. This patch makes necessary changes.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
