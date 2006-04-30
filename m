From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: determine outgoing interface (eth0,eth1) for a packet according to the dest IP
Date: Sun, 30 Apr 2006 11:17:11 +0200
Message-ID: <20060430091711.GL24458@xi.wantstofly.org>
References: <ada605fb0604260324n4dc99556j300bfd433a9027d9@mail.gmail.com> <E1FYkWm-0003MM-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Que <qwejohn@gmail.com>, ak@suse.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:26241 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1751073AbWD3JRN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Apr 2006 05:17:13 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1FYkWm-0003MM-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 26, 2006 at 11:58:00PM +1000, Herbert Xu wrote:

> > I had spent time trying to write something which
> > uses RTA_SRC and RTA_DST and got some problems.
> > (I probably made something stupid.)
> > I googled for such examples and did not get much.
> > I saw that the zebra project and iproute uses
> > netlinks but it is complex.,
> 
> Have a look at
> 
> http://gondor.apana.org.au/~herbert/findsaddr-linux.c
> 
> which I wrote for traceroute some years back.

A fragile and ugly but easier/shorter way of getting the source address
(which I've used a couple of times in the past) is to open a SOCK_DGRAM
socket, connect() it to the intended destination, and then do
getsockname().

(That doesn't give you the interface, though.)


--L
