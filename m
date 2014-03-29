From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [ANNOUNCE] Enhanced IP
Date: Sat, 29 Mar 2014 12:10:18 +0100
Message-ID: <20140329111018.GF11063@order.stressinduktion.org>
References: <CABvMDUef6i=aKy8=ZRvs8q6vYQh08d2UfAni-o8Ee=80Gz=ewA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Sam Patton <sam@enhancedip.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38996 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbaC2LKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 07:10:19 -0400
Content-Disposition: inline
In-Reply-To: <CABvMDUef6i=aKy8=ZRvs8q6vYQh08d2UfAni-o8Ee=80Gz=ewA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2014 at 09:41:59PM -0400, Sam Patton wrote:
> The February edition of IEEE Computer has a paper on Enhanced IP, an
> alternative to Ipv6.  Enhanced IP developers have released a version
> of the software in the form of virtual machines, which are designed to
> be used by other kernel developers. At this point, the project is
> interested in attracting kernel developers who want to write network
> code.  The primary website for Enhanced IP is www.enhancedip,org.

The name 'EnhancedIP' may make it too much obvious that the protocol
tries to compete with IPv6 etc. This might make problems if you
at some point try to push this through IETF standardization because of
policitical reasons to try to stick to a single-protocol internet approach
(although it has IP in it). I don't know for sure...

I think a name with 'tunnel' in it might have much better chances in
discussions. ;)

For me, the protocol seems to have enough value in it to get used, but
IMHO this doesn't depend on the protocol itself so much, but on the API
towards the user. It would be best if old applications could just use this
protocol without any change, but this might be very difficult. Somehow
during history user applications got exposed to binary fixed-length
addresses, and they even try to interpret them sometimes. For me this
seems to be the hardest nut to crack.

As a hack one could try to expose sockaddr_ein as sockaddr_in6 as it
has enough storage and people already seem to implement IPv6 API.

In case you want to try to push the protocol upstream I would suggest that
you might send RFC patches early on to this list so that people might
have a look and give feedback early on. In the paper you state that it
currently only needs 700 lines of code (without icmp handling?),
so I guess people here would browse through the code and comment on it.

> Here's the abstract from the paper:
> 
> Enhanced IP (EnIP) offers a solution to the problem of IPv4 address
> depletion without replacing IPv4, as IPv6 does, but by building on top
> of IPv4, maximizing backward compatibility. An experimental EnIP
> deployment between nodes at the University of Maryland and the
> University of Delaware, requiring neither software modification nor
> modification of in-path routers, demonstrates EnIP's potential.

Sorry, I don't have anything to add from a technical PoV currently.

Bye,

  Hannes
