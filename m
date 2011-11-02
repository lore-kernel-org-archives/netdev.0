From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux 3.1-rc9
Date: Wed, 02 Nov 2011 19:04:34 +0100
Message-ID: <1320257074.2292.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318874090.4172.84.camel@twins>
	  <CA+55aFwCBy=4YK6amE=H-BYu9-boj4Po2Zkgf4V261mCx0DC4A@mail.gmail.com>
	  <1318879396.4172.92.camel@twins>
	 <alpine.LFD.2.02.1110172237030.3240@ionos>
	  <alpine.LFD.2.02.1110181037120.3240@ionos>
	 <1318928713.21167.4.camel@twins> <20111018182046.GF1309@hostway.ca>
	  <alpine.LFD.2.02.1110182146440.3240@ionos>
	  <20111024190203.GA24410@hostway.ca> <20111025202049.GB25043@hostway.ca>
	  <20111031173246.GA10614@hostway.ca>
	  <alpine.LFD.2.02.1111021725550.2829@ionos>
	 <1320254854.2292.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.LFD.2.02.1111021849170.2829@ionos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Simon Kirby <sim@hostway.ca>, David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Network Development <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44860 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755870Ab1KBSEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 14:04:39 -0400
In-Reply-To: <alpine.LFD.2.02.1111021849170.2829@ionos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 novembre 2011 =C3=A0 18:54 +0100, Thomas Gleixner a =C3=A9=
crit :

> The same applies for if (__inet_inherit_port(sk, newsk) < 0) a few
> lines further down, but that part was leaking the lock before that
> commit already.
>=20

Yes, but in normal condition, this never happened, this is why this
problem was never noticed.

tproxy is probaby very seldom used, and when used the error path is
probably never reached...
