From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6_tunnel: copy parms.name after register_netdevice
Date: Mon, 14 Nov 2011 00:24:56 -0500 (EST)
Message-ID: <20111114.002456.1590067179487443754.davem@davemloft.net>
References: <20111111011023.GE2170@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: jwboyer@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111111011023.GE2170@zod.bos.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josh Boyer <jwboyer@redhat.com>
Date: Thu, 10 Nov 2011 20:10:23 -0500

> @@ -288,6 +288,8 @@ static struct ip6_tnl *ip6_tnl_create(struct net *net, struct ip6_tnl_parm *p)
>  
>  	if ((err = register_netdevice(dev)) < 0)
>  		goto failed_free;
> +	
> +	strcpy(t->parms.name, dev->name);

Trailing whitespace on that blank line you're adding.

I fixed this up, applied, and queued up for -stable, thanks.
