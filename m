From: Oskar Andreasson <blueflux@koffein.net>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Fri, 12 Sep 2003 12:56:32 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0309121244400.2544@oskar-lap.agatha>
References: <200309022116.41697.bdschuym@pandora.be> <20030903200426.59d0af4a.davem@redhat.com>
 <20030905153152.GA3623@obroa-skai.de.gnumonks.org> <1063330846.1028.11.camel@jzny.localdomain>
 <20030912085606.GC2350@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@redhat.com>,
   Bart De Schuymer <bdschuym@pandora.be>, acme@conectiva.com.br,
   netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20030912085606.GC2350@obroa-skai.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Fri, 12 Sep 2003, Harald Welte wrote:

<snip>
>
> Imagine somebody with lots of ppp interfaces (let's say 40)... and we
> would need to resolve all 40 into ifindexes, put them into an array...
> how big would you like to make the array?  how many interfaces do people
> have? how much space do you want to waste (dynamically reallocating this
> space while the ruleset is already loaded is not possible).
>

Just to add my point o this, and to say that it is actually used in
real-world. We have several (>30) machines with 120 modems each, each
running a pppd (modem pool, yes), and some  300-400 iptables rules on each
machine.

> And then you have 1000 rules, each of it using a ppp* style match. than
> at every ifdown/ifup you iterate over 1000 rules, checking if you need
> to update one of the 40 ifindexes?  quite slow...
>
> > cheers,
> > jamal
> - Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/

----
Oskar Andreasson
http://www.frozentux.net
http://iptables-tutorial.frozentux.net
http://ipsysctl-tutorial.frozentux.net
mailto:blueflux@koffein.net
