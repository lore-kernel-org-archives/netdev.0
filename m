From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 2/6][INET]: Consolidate inet(6)_hash_connect.
Date: Thu, 31 Jan 2008 11:39:55 -0200
Message-ID: <20080131133954.GU1819@ghostprotocols.net>
References: <47A1BFC9.2030603@openvz.org> <20080131130153.GP1819@ghostprotocols.net> <47A1CABB.8050805@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34126 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764649AbYAaNkA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 08:40:00 -0500
Content-Disposition: inline
In-Reply-To: <47A1CABB.8050805@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Jan 31, 2008 at 04:18:51PM +0300, Pavel Emelyanov escreveu:
> Arnaldo Carvalho de Melo wrote:
> > Em Thu, Jan 31, 2008 at 03:32:09PM +0300, Pavel Emelyanov escreveu:
> >> These two functions are the same except for what they call
> >> to "check_established" and "hash" for a socket.
> >>
> >> This saves half-a-kilo for ipv4 and ipv6.
> > 
> > Good stuff!
> > 
> > Yesterday I was perusing tcp_hash and I think we could have the hashinfo
> > pointer stored perhaps in sk->sk_prot.
> > 
> > That way we would be able to kill tcp_hash(), inet_put_port() could
> > receive just sk, etc.
> 
> But each proto will still have its own hashfn, so proto's 
> callbacks will be called to hash/unhash sockets, so this will 
> give us just one extra dereference. No?
> 
> > What do you think?
> 
> Hmmm... Even raw_hash, etc may become simpler. On the other hand
> maybe this is a good idea, but I'm not very common with this code
> yet to foresee such things in advance... I think that we should
> try to prepare a patch and look, but if you have smth ready, then
> it's better to review your stuff first.

gimme some minutes

- Arnaldo
