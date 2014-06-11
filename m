From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_tunnel: fix i_key matching in ip_tunnel_find
Date: Wed, 11 Jun 2014 00:43:50 -0700 (PDT)
Message-ID: <20140611.004350.1837802675812645079.davem@davemloft.net>
References: <20140608030308.77bc67a743827807737268f1@qrator.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ixaphire@qrator.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140608030308.77bc67a743827807737268f1@qrator.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Popov <ixaphire@qrator.net>
Date: Sun, 8 Jun 2014 03:03:08 +0400

> Some tunnels (though only vti as for now) can use i_key just for internal use: 
> for example vti uses it for fwmark'ing incoming packets. So raw i_key value 
> shouldn't be treated as a distinguisher for them. ip_tunnel_key_match exists for
> cases when we want to compare two ip_tunnel_parms' i_keys.
> 
> Example bug:
> ip link add type vti ikey 1 local 1.0.0.1 remote 2.0.0.2
> ip link add type vti ikey 2 local 1.0.0.1 remote 2.0.0.2
> spawned two tunnels, although it doesn't make sense.
> 
> Signed-off-by: Dmitry Popov <ixaphire@qrator.net>

Applied, thanks.
