From: jamal <hadi@cyberus.ca>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: 11 Sep 2003 21:40:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063330846.1028.11.camel@jzny.localdomain>
References: <200309022116.41697.bdschuym@pandora.be>
	 <20030903200426.59d0af4a.davem@redhat.com>
	 <20030905153152.GA3623@obroa-skai.de.gnumonks.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
   Bart De Schuymer <bdschuym@pandora.be>, acme@conectiva.com.br,
   netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20030905153152.GA3623@obroa-skai.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Harald,

Could you not resolve all the ifindices of the said ppp+ interfaces
at rule installation time and do an integer compare instead?

cheers,
jamal

On Fri, 2003-09-05 at 11:31, Harald Welte wrote:

> > 
> > Please, just remove the super-silly memcmp() optimization in
> > the ipt_physdev.c code.
> 
> Dave, the respective code in ipt_physdev.c seems to be copied from
> the ip_tables.c interface name match (which definitely has the same
> alignment issues, btw).
> 
> The problem is that it is _not_ a simple reimplementation of memcmp(),
> but a mask-compare.
> 
> People can do stuff like "-i ppp+", meaning that traffic from all
> interfaces called "ppp<WHATEVER>" are matched.
