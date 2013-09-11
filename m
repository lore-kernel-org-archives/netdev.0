From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH 1/1] net: sched: Make netns available for ematch
 extensions
Date: Wed, 11 Sep 2013 20:37:35 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1309112028160.30567@blackhole.kfki.hu>
References: <1378905614-29691-1-git-send-email-kadlec@blackhole.kfki.hu>  <1378905614-29691-2-git-send-email-kadlec@blackhole.kfki.hu>  <1378909915.21474.2.camel@edumazet-glaptop> <1378909978.21474.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"V. Lavrov" <lve@guap.ru>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-in.kfki.hu ([148.6.0.25]:34266 "EHLO smtp0.kfki.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752509Ab3IKShh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Sep 2013 14:37:37 -0400
In-Reply-To: <1378909978.21474.3.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Sep 2013, Eric Dumazet wrote:

> On Wed, 2013-09-11 at 07:31 -0700, Eric Dumazet wrote:
> 
> > Note that qdisc_dev(tp->q) should give you the pointer to device
> > 
> > Then ->nd_net gives you the struct net pointer.
> > 
> > On management path, this should be enough ;)

Ohh, this is great, thanks indeed! Somehow I overlooked tp->q when 
searching to find a pointer to struct net.

> (A device can be moved from net xxxx to net yyyy)

So something like dev_net(qdisc_dev(tp->q)) is all what we need.
 
Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
