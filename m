From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Advice needed on IP-over-InfiniBand driver
Date: Sun, 19 Sep 2004 19:34:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919193415.6dc96cab.davem@davemloft.net>
References: <52fz5esxx6.fsf@topspin.com>
	<20040919140133.60ea3fb3.davem@davemloft.net>
	<1095628759.1049.22.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: roland@topspin.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1095628759.1049.22.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 19 Sep 2004 17:19:19 -0400
jamal <hadi@cyberus.ca> wrote:

> Probably just easier to have his own private tables holding reference to
> neighbor entries instead of polluting the neighbor tables.
> Listens to ARP events - on state transition to/from reachable state he
> queries his remote manager. 
> Curious though if ARP still works even when that "path" thing hasnt been
> resolved.

It sounds like a two-stage thing, the first stage lets you talk
on the subnet and get to the IB subnet manager, and the second
stage lets you acually speak IP.  My understanding, from his
description, is that once the second stage part is complete you
don't need to first stage address information at all.

The reason I suggested the scheme the way that I did was so
that the hh_cache can work fully for IP over IB.
