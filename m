From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH 1/1] Introduce notification events for routing changes
Date: Thu, 29 Nov 2012 10:05:16 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1211291002520.23615@blackhole.kfki.hu>
References: <1354048045-17846-1-git-send-email-kadlec@blackhole.kfki.hu> <1354048045-17846-2-git-send-email-kadlec@blackhole.kfki.hu> <20121128.175929.618012822860698468.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20121128.175929.618012822860698468.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Nov 2012, David Miller wrote:

> > The netfilter MASQUERADE target does not handle the case when the routing
> > changes and the source address of existing connections become invalid.
> > The problem can be solved if routing modifications create events to which
> > the MASQUERADE target can subscribe and then delete the affected
> > connections.
> > 
> > The patch adds the required event support for IPv4/IPv6.
> > 
> > Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> 
> What part of the information are you actually interested in?
> 
> Because just saying that a route is added or removed using fib_info X
> doesn't tell you a whole lot.
[...]

Please discard my patch. I found a simpler and more efficient way to solve 
the issue in netfilter itself.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
