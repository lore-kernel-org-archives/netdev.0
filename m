From: Andreas Schwab <schwab@suse.de>
Subject: Re: [Bugme-new] [Bug 9816] New: cannot replace route
Date: Sat, 26 Jan 2008 15:27:00 +0100
Message-ID: <jeve5gd5mz.fsf@sykes.suse.de>
References: <bug-9816-10286@http.bugzilla.kernel.org/>
	<20080125142603.a73fd7a2.akpm@linux-foundation.org>
	<479A6CBD.4010908@gmail.com>
	<20080125192026.e667f396.akpm@linux-foundation.org>
	<b25c3fa70801252116h2b9f12c9j65a8a75dbd0d5662@mail.gmail.com>
	<20080126114036.GA2624@ami.dom.local>
	<20080126141010.GC2624@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joonwoo Park <joonwpark81@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:39962 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753118AbYAZO1E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jan 2008 09:27:04 -0500
In-Reply-To: <20080126141010.GC2624@ami.dom.local> (Jarek Poplawski's message
	of "Sat\, 26 Jan 2008 15\:10\:10 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> writes:

> And, after re-reading this bugzilla report, I'm pretty sure the thing
> should be done with 'ip route change' (but I didn't check if 2.6.24
> knows about this...).

$ man ip
[...]
   ip route add - add new route
   ip route change - change route
   ip route replace - change or add new one
[...]

According to this "replace" should be a superset of "change".

Also, please check out comment#3, it also fails for replacing a route
with something different (it's a route to an ipsec tunnel).

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4=
ED5
"And now for something completely different."
