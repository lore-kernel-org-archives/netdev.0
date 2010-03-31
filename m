From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
 policy->walk.dead
Date: Wed, 31 Mar 2010 09:28:12 -0400
Message-ID: <1270042092.26743.26.camel@bigi>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>
	 <1270030626-16687-5-git-send-email-timo.teras@iki.fi>
	 <20100331110345.GC12845@gondor.apana.org.au>
	 <1270040773.26743.12.camel@bigi>
	 <20100331131131.GA13793@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:55638 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757451Ab0CaN2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 09:28:16 -0400
Received: by qyk9 with SMTP id 9so90070qyk.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 06:28:15 -0700 (PDT)
In-Reply-To: <20100331131131.GA13793@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-31 at 21:11 +0800, Herbert Xu wrote:

> I disagree.  A flush event is a signal that someone has sent a
> flush command.  

Sorry - I respectfully disagree.

> In any case we've had this semantics for years
> and I haven't heard a good reason why this should be changed.

It generates unnecessary noise and it is a deviation like i mentioned.

> > This is a consistent definition of the semantics everywhere tables
> > are flushed (not just in Linux)..
> 
> Please give specific examples in the kernel.

Something i can do safely right now without messing my connection; 
Issue iproute commands in one window, observe events in another

-sudo ip route add 192.168.11.100 dev eth0 table 15
generates an event
-sudo ip route flush table 15
generates an event
-sudo ip route flush table 15
No event

But pick anything else in the other netlink knowledgeable subsystem
and youd see similar behavior.

If there was an app depending on this behavior - thats a separate reason
(but thats not the arguement you are making).

cheers,
jamal

