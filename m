From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 15507] New: kernel misses 3rd part of tcp
 handshake (ACK), stays in SYN_RECV state
Date: Fri, 19 Mar 2010 14:42:09 +0100
Message-ID: <1269006129.3048.36.camel@edumazet-laptop>
References: <bug-15507-10286@http.bugzilla.kernel.org/>
	 <20100318160103.cc28c367.akpm@linux-foundation.org>
	 <1268953951.2894.194.camel@edumazet-laptop>  <4BA365BA.4040309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Joshua Roys <roysjosh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:46929 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411Ab0CSNmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 09:42:16 -0400
Received: by bwz1 with SMTP id 1so37710bwz.21
        for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 06:42:14 -0700 (PDT)
In-Reply-To: <4BA365BA.4040309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 mars 2010 =C3=A0 07:53 -0400, Joshua Roys a =C3=A9crit :
> On 03/18/2010 07:12 PM, Eric Dumazet wrote:
> >
> > I would say this is expected if httpd server set DEFER_ACCEPT socke=
t
> > option.
> >
> >
> >
>=20
> Gah!  You've got to be kidding :)  If that's what it is, close the=20
> bug...  and I'll go read some man-pages!
>=20

So you _confirm_ DEFER_ACCEPT is not used, its _important_ for us.

I dont believe my comment was trivial at all :)

I gave a hint to myself and other network guys, because we did some
changes in this area lately (commit b103cf34 tcp: fix TCP_DEFER_ACCEPT
retrans calculation) from Julian Anastasov.

git describe b103cf34
v2.6.31-9056-gb103cf3

Please boot a fresh vm, then try exactly 10 'bad connects', please make
each attempt last at least 2 minutes. (you can start all these in
parallel)

And report :

netstat -s


(My FC12 copy doesnt exhibit this problem)

Thanks


