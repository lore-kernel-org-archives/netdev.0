From: Unknown <borg@uu3.net>
Subject: Re: [Bugme-new] [Bug 16216] New: wrong source addr of UDP packets
 when using policy routing
Date: Fri, 18 Jun 2010 11:56:49 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1006181146100.2662@cube>
References: <bug-16216-10286@https.bugzilla.kernel.org/>
 <20100616093328.0671254b.akpm@linux-foundation.org>  <4C18FFDC.8060102@trash.net>
 <1276709309.2632.126.camel@edumazet-laptop> <4C190D34.8080100@trash.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811584-399203403-1276855009=:2662"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.uu3.net ([87.99.63.19]:59501 "EHLO borg.uu3.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755871Ab0FRKX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jun 2010 06:23:59 -0400
In-Reply-To: <4C190D34.8080100@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811584-399203403-1276855009=:2662
Content-Type: TEXT/PLAIN; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE

Okey. Did you people came into any conclusions?
Is there a patch I can test?

I tried to find 914a9ab386a288d0f22252fc268ecbc048cdcbd5
in few stable trees but was unable to.

---------- Original message ----------

From: Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
    bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org,
    borg@uu3.net
Subject: Re: [Bugme-new] [Bug 16216] New: wrong source addr of UDP packets =
when
    using policy routing
Date: Wed, 16 Jun 2010 19:43:16 +0200
Message-ID: <4C190D34.8080100@trash.net>

Eric Dumazet wrote:
> Le mercredi 16 juin 2010  18:46 +0200, Patrick McHardy a =E9crit :
>=20
>  =20
> > This is know behaviour, fwmarks don't work for source address selection
> > since before the source address is chosen, you don't even have a packet
> > which could be marked.
> >    =20
>=20
> We know have sk->sk_mark routing (socket based), so we might change
> sk->sk_mark with appropriate iptables target when one packet is
> received... not very clean but worth to mention...
>  =20
That would still be too late. The proper way would be to have the applicati=
on
set the socket mark.
---1463811584-399203403-1276855009=:2662--
