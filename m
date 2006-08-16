From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/9] network namespaces: core and device list
Date: Wed, 16 Aug 2006 09:45:28 -0700
Message-ID: <20060816094528.0b65cbab@localhost.localdomain>
References: <20060815182029.A1685@castle.nmd.msu.ru>
	<20060815184836.A2882@castle.nmd.msu.ru>
	<1155739603.8377.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrey Savochkin <saw@sw.ru>, netdev@vger.kernel.org,
	dlezcano@fr.ibm.com, serue@us.ibm.com, clg@fr.ibm.com,
	herbert@13thfloor.at, sam@vilain.net, ebiederm@xmission.com,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, devel@openvz.org,
	alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13288 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750983AbWHPQqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 12:46:31 -0400
To: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1155739603.8377.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 16 Aug 2006 07:46:43 -0700
Dave Hansen <haveblue@us.ibm.com> wrote:

> On Tue, 2006-08-15 at 18:48 +0400, Andrey Savochkin wrote:
> > 
> >         /* Can survive without statistics */
> >         stats = kmalloc(sizeof(struct net_device_stats), GFP_KERNEL);
> >         if (stats) {
> >                 memset(stats, 0, sizeof(struct net_device_stats));
> > -               loopback_dev.priv = stats;
> > -               loopback_dev.get_stats = &get_stats;
> > +               dev->priv = stats;
> > +               dev->get_stats = &get_stats;
> >         } 
> 
> With this much surgery it might be best to start using things that have
> come along since this code was touched last, like kzalloc().
> 
>

If you are going to make the loopback device dynamic, it MUST use
alloc_netdev().
