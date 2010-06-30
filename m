From: Simon Horman <horms@verge.net.au>
Subject: Re: nat bypass
Date: Wed, 30 Jun 2010 11:37:18 +0900
Message-ID: <20100630023718.GU2138@verge.net.au>
References: <AANLkTil_H1QeaCHQYhMjVRFiLwtqF9yLAJZ9BWecOIDW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netfilter mailing list <netfilter@vger.kernel.org>,
	netdev@vger.kernel.org
To: ratheesh k <ratheesh.ksz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:41484 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750869Ab0F3ChV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jun 2010 22:37:21 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTil_H1QeaCHQYhMjVRFiLwtqF9yLAJZ9BWecOIDW@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 28, 2010 at 03:43:46PM +0530, ratheesh k wrote:
> Hi,
> 
>   A -------> R ------->S
> 
> I have a linux machine A is connected to Linux machine R . Machine R
> is having two network interfaces and acting as a router .
> It has a dhcp server running  . It will assign ip in 192.168.1.0/24
> subnet to all machine connected on lan side ( A is connected also in
> lan side ) . Wan side of R is connected to HTTP server S . There is
> also a DHCP server running on S to assign ip in 10.232.18.0/24 subnet
> .  Is there any way , in which NAT should be bypassed to get ip from
> DHCP server running  on S . My question is : How can A will get  an ip
> from 10.232.18.0/24 pool ip .?
> ebtables is an option ? How can we make it ?
> Is there any other optimal way ?

Let me try and understand this.

R is routing between 192.168.1.0/24 and 10.232.18.0/24.
As A is on the 192.168.1.0/24 side of R.
But to give A an 10.232.18.0/24 address (dynamically)?

Why?

