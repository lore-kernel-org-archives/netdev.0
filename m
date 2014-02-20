From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Getting a NIC's MTU size
Date: Thu, 20 Feb 2014 19:12:52 +0100
Message-ID: <20140220181252.GA15495@order.stressinduktion.org>
References: <20140217.002153.1121569813590047048.davem@davemloft.net> <26474.1392388608@warthog.procyon.org.uk> <26769.1392390042@warthog.procyon.org.uk> <27696.1392392957@warthog.procyon.org.uk> <16869.1392917423@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:41343 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbaBTSMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 13:12:53 -0500
Content-Disposition: inline
In-Reply-To: <16869.1392917423@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 20, 2014 at 05:30:23PM +0000, David Howells wrote:
> David Miller <davem@davemloft.net> wrote:
> 
> > > One further question: If I want to get the MTU size of the NIC through
> > > which packets will go to get to a particular peer, can I do:
> > 
> > As has been suggested or at least hinted to by others, you have to use
> > the route dst's device pointer.
> 
> So I gather.  My query was intended to be about the safety of accessing the
> dst->dev pointer.  Can I just dereference it?  Or do I need to take a lock or
> use RCU?

No, you can just dereference it. dst holds a reference on ->dev, so it
is safe without lock or rcu as long as dst is alive and referenced.

Greetings,

  Hannes
