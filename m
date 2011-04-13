From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 32832] New: shutdown(2) does not fully shut
 down socket any more
Date: Wed, 13 Apr 2011 05:00:08 +0200
Message-ID: <1302663608.2811.62.camel@edumazet-laptop>
References: <bug-32832-10286@https.bugzilla.kernel.org/>
	 <20110412161556.0641bdae.akpm@linux-foundation.org>
	 <20110412.161744.27803776.davem@davemloft.net>
	 <1302663327.2811.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, kees@outflux.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61604 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756095Ab1DMDAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 23:00:13 -0400
Received: by wwa36 with SMTP id 36so212262wwa.1
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 20:00:12 -0700 (PDT)
In-Reply-To: <1302663327.2811.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 13 avril 2011 =C3=A0 04:55 +0200, Eric Dumazet a =C3=A9crit=
 :

> Since SO_REUSEPORT is not a 'stable fix', I suggest we revert the pat=
ch,
> and eventually work on SO_REUSEPORT on net-next-2.6
>=20
> What do you think ?
>=20

Sorry, I should have mentioned commit id : c191a836a908d1dd6
(tcp: disallow bind() to reuse addr/port)



