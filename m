From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [stable] netfilter: ipset: Check and reject crazy /0 input
 parameters
Date: Tue, 24 Dec 2013 23:42:53 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1312242342240.22624@blackhole.kfki.hu>
References: <20131222015933.GA30757@nitrogen.neutroncom.local> <1387854004.2783.38.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Neutron Soutmun <neo.neutron@gmail.com>,
	732689@bugs.debian.org, netdev <netdev@vger.kernel.org>,
	stable@vger.kerne.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.kfki.hu ([148.6.0.26]:46289 "EHLO smtp1.kfki.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751007Ab3LXWm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Dec 2013 17:42:58 -0500
In-Reply-To: <1387854004.2783.38.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Dec 2013, Ben Hutchings wrote:

> This fix went into Linux 3.7:
> 
> commit b9fed748185a96b7cfe74afac4bd228e8af16f01
> Author: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> Date:   Tue Sep 4 17:45:59 2012 +0200
> 
>     netfilter: ipset: Check and reject crazy /0 input parameters
>     
>     bitmap:ip and bitmap:ip,mac type did not reject such a crazy range
>     when created and using such a set results in a kernel crash.
>     The hash types just silently ignored such parameters.
>     
>     Reject invalid /0 input parameters explicitely.
>     
>     Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> 
> Should it also go into stable 3.x.y updates?  I checked that it applies
> and builds cleanly on top of 3.2.53.

Yes, it should go into the stable updates too.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
