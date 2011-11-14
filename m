From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: [PATCH] ip6_tunnel: copy parms.name after register_netdevice
Date: Mon, 14 Nov 2011 09:02:53 -0500
Message-ID: <20111114140253.GA4096@zod.bos.redhat.com>
References: <20111111011023.GE2170@zod.bos.redhat.com>
 <20111114.002456.1590067179487443754.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jpirko@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111114.002456.1590067179487443754.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 14, 2011 at 12:24:56AM -0500, David Miller wrote:
> From: Josh Boyer <jwboyer@redhat.com>
> Date: Thu, 10 Nov 2011 20:10:23 -0500
> 
> > @@ -288,6 +288,8 @@ static struct ip6_tnl *ip6_tnl_create(struct net *net, struct ip6_tnl_parm *p)
> >  
> >  	if ((err = register_netdevice(dev)) < 0)
> >  		goto failed_free;
> > +	
> > +	strcpy(t->parms.name, dev->name);
> 
> Trailing whitespace on that blank line you're adding.

Ugh.  Forgot to run checkpatch.  Apologies.

> I fixed this up, applied, and queued up for -stable, thanks.

Thank you.

josh
