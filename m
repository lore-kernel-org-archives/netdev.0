From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [Bugme-new] [Bug 11469] New: TUN with 1024 neighbours: ip6_dst_lookup_tail NULL crash
Date: Sun, 7 Sep 2008 21:19:49 +0300
Message-ID: <200809072119.50307.rdenis@simphalempin.com>
References: <bug-11469-10286@http.bugzilla.kernel.org/> <20080831111304.d57b9f5a.akpm@linux-foundation.org> <20080907181109.GA2466@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:39822 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754138AbYIGSTy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2008 14:19:54 -0400
In-Reply-To: <20080907181109.GA2466@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 7 septembre 2008 21:11:09 Evgeniy Polyakov, vous avez =E9cr=
it=A0:
> Since dst entry is allowed not to have neighbour entry, flush it just
> like with incomplete one. This drops performance of your application
> with more than 1024 neighbours to 1024 messages, to fix it you should
> tune ipv6 routing parameters (gc intervals, gc threshold, maximum num=
ber
> of entries and so on). There may be another problem with perfomance
> though, at least I was able to bump it 10 times with different settin=
gs,
> but still two times smaller than with 4k neighbours.

That looks like a trivial local DoS against the IPv6 stack though?

Especially in the case that the interface has IFF_NOARP, that seems lik=
e a=20
weird limitation. Oh well...

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
