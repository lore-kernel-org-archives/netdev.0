From: Dax Kelson <dax@gurulabs.com>
Subject: Re: port-based filtering of ESP packets with in-kernel IPsec?
Date: 30 Jul 2003 16:51:34 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1059605494.3284.141.camel@mentor.gurulabs.com>
References: <1059540296.16545.305.camel@k7.localnet>
	 <20030730142411.GD4553@sunbeam.de.gnumonks.org>
	 <1059576701.4586.20.camel@simulacron>
	 <1059597421.3284.7.camel@mentor.gurulabs.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, netfilter-devel@lists.netfilter.org,
   netfilter@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Jellinghaus <aj@dungeon.inka.de>
In-Reply-To: <1059597421.3284.7.camel@mentor.gurulabs.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-07-30 at 14:37, Dax Kelson wrote:
> On Wed, 2003-07-30 at 08:51, Andreas Jellinghaus wrote:
> > [netfilter]
> > incoming encrypted packets are seen as ESP/AH in INPUT
> > and then as decrypted packet in INPUT or FORWARD.
> 
> Just to clarify, the packets will travel INPUT *twice* (once as ESP and
> then in the clear)?

If this is the case, then I see a problem.

If you have an explicit drop/reject all the bottom (or have a DROP
policy) of INPUT then no IPSEC traffic would be allowed.

I supposed you could add a rule that allowed all ESP traffic before the
the explicit drop.

Dax
