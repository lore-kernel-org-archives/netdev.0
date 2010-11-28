From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] net-next: Fix __inet_inherit_port() to correctly
 increment bsockets and num_owners
Date: Mon, 29 Nov 2010 02:00:41 +0300
Message-ID: <20101128230041.GA16269@ioremap.net>
References: <844781.48196.qm@web53701.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Nagendra Tomar <tomer_iisc@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.ru ([195.178.208.66]:35825 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752097Ab0K1XAo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Nov 2010 18:00:44 -0500
Content-Disposition: inline
In-Reply-To: <844781.48196.qm@web53701.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Fri, Nov 26, 2010 at 04:26:27PM -0800, Nagendra Tomar (tomer_iisc@yahoo.com) wrote:
> inet sockets corresponding to passive connections are added to the bind hash
> using ___inet_inherit_port(). These sockets are later removed from the bind 
> hash using __inet_put_port(). These two functions are not exactly symmetrical. 
> __inet_put_port() decrements hashinfo->bsockets and tb->num_owners, whereas 
> ___inet_inherit_port() does not increment them. This results in both of these 
> going to -ve values.
> 
> This patch fixes this by calling inet_bind_hash() from ___inet_inherit_port(),
> which does the right thing.
> 
> 'bsockets' and 'num_owners' were introduced by commit a9d8f9110d7e953c 
> (inet: Allowing more than 64k connections and heavily optimize bind(0))

Yup, things changed from that simple patch a lot.
Thanks for fixing it up.
Ack.

-- 
	Evgeniy Polyakov
