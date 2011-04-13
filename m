From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 32832] New: shutdown(2) does not fully shut
 down socket any more
Date: Wed, 13 Apr 2011 10:51:22 +0200
Message-ID: <1302684682.2813.1.camel@edumazet-laptop>
References: <bug-32832-10286@https.bugzilla.kernel.org/>
	 <20110412.161744.27803776.davem@davemloft.net>
	 <1302663327.2811.55.camel@edumazet-laptop>
	 <201104130906.19882.cyril.bonte@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, kees@outflux.net
To: Cyril =?ISO-8859-1?Q?Bont=E9?= <cyril.bonte@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56927 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132Ab1DMIv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 04:51:28 -0400
Received: by wwa36 with SMTP id 36so459986wwa.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 01:51:26 -0700 (PDT)
In-Reply-To: <201104130906.19882.cyril.bonte@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 13 avril 2011 =C3=A0 09:06 +0200, Cyril Bont=C3=A9 a =C3=A9=
crit :
> Le mercredi 13 avril 2011 04:55:27, Eric Dumazet a =C3=A9crit :
> > I worked on it this week end to discover FreeBSD 8.1 would not allo=
w
> > several CLOSE sockets bound to same port even with REUSEADDR.
>=20
> Just to complete the information, yes it does, but only after a shutd=
own()=20
> call. And this is the use case of haproxy, amavisd (quoted in the bug=
zilla bug=20
> report), and others.

Yes, but after a shutdown(), FreeBSD doesnt allow a reuse of the socket=
=2E
listen() is not available anymore. Its a bit like an unbind, or a full
close().



