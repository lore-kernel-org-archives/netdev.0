From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: optimise inet_proto_csum_replace4()
Date: Fri, 26 Sep 2014 16:14:46 -0400 (EDT)
Message-ID: <20140926.161446.2185318574555478975.davem@davemloft.net>
References: <20140923085437.696B81AB26D@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, edumazet@google.com,
	netdev@vger.kernel.org
To: christophe.leroy@c-s.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140923085437.696B81AB26D@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Tue, 23 Sep 2014 10:54:37 +0200 (CEST)

> csum_partial() is a generic function which is not optimised for small fixed
> length calculations, and its use requires to store "from" and "to" values in
> memory while we already have them available in registers. This also has impact,
> especially on RISC processors. In the same spirit as the change done by
> Eric Dumazet on csum_replace2(), this patch rewrites inet_proto_csum_replace4()
> taking into account RFC1624.
> 
> I spotted during a NATted tcp transfert that csum_partial() is one of top 5
> consuming functions (around 8%), and the second user of csum_partial() is 
> inet_proto_csum_replace4().
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

Also applied, thanks Christophe.
