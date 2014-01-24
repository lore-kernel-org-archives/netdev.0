From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Setting mac address of loopback device
Date: Fri, 24 Jan 2014 01:10:26 +0100
Message-ID: <20140124001026.GN7269@order.stressinduktion.org>
References: <CAHA+R7Poj99BjOq55st3hU-2-p+gqoeHMCDCSJjT5eEocbKwMQ@mail.gmail.com> <20140123234920.GM7269@order.stressinduktion.org> <CAHA+R7PtkiQRgJwTJ4Pq2zTWs9N5x22VFEcK4QMv65SG7bX1Tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33567 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbaAXAK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 19:10:27 -0500
Content-Disposition: inline
In-Reply-To: <CAHA+R7PtkiQRgJwTJ4Pq2zTWs9N5x22VFEcK4QMv65SG7bX1Tw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 23, 2014 at 04:03:29PM -0800, Cong Wang wrote:
> On Thu, Jan 23, 2014 at 3:49 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > On Thu, Jan 23, 2014 at 11:53:49AM -0800, Cong Wang wrote:
> >> BTW, how to change route to redirect _local_ traffic (that is packets
> >> sending to itself) to a non-loopback device? I tried to modify local
> >> route table, but have no luck to make it working.
> >
> > Have you seen the route_localnet sysctl? It should avoid the check for
> > loopback addresses when building outgoing route.
> 
> I noticed it, the doc said:
> 
> This enables the use of 127/8 for local routing purposes.
> 
> but I don't care 127/8 traffic at all, only the traffic sending to itself
> via a non-127/8 IP. :(
> 
> Or the doc is not accurate?

It seems accurate. Only other idea is to try netfilter with TEE target on
loopback.

Greetings,

  Hannes
