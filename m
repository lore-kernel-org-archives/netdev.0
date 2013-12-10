From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next] neigh: use neigh_parms_net() to get struct
 neigh_parms->net pointer
Date: Tue, 10 Dec 2013 15:09:25 -0800
Message-ID: <1386716965.30495.350.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386716107-18843-1-git-send-email-jiri@resnulli.us>
	 <20131210.175929.828518960842627263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:44956 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776Ab3LJXJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 18:09:29 -0500
Received: by mail-yh0-f49.google.com with SMTP id z20so4469210yhz.36
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 15:09:28 -0800 (PST)
In-Reply-To: <20131210.175929.828518960842627263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-10 at 17:59 -0500, David Miller wrote:
> From: Jiri Pirko <jiri@resnulli.us>
> Date: Tue, 10 Dec 2013 23:55:07 +0100
> 
> > This fixes compile error when CONFIG_NET_NS is not set.
> > 
> > Introduced by:
> > commit 1d4c8c29841b9991cdf3c7cc4ba7f96a94f104ca
> >     "neigh: restore old behaviour of default parms values"
> > 
> > Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>  ...
> > -	struct net *net = p->net;
> > +	struct net *net = neigh_parms_net(p);
> 
> Hey look at that, the interface already existed :-)

Yep, provided in commit e42ea986e4a4ca about 5 years ago ;)
