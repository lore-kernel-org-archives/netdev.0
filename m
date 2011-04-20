From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Wed, 20 Apr 2011 10:09:58 +0200
Message-ID: <1303286998.3186.18.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <20110418153852.153d3ed3.akpm@linux-foundation.org>
	 <1303181466.4152.39.camel@edumazet-laptop>
	 <1303182557.4152.48.camel@edumazet-laptop>
	 <1303183217.4152.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191210011.17888@router.home>
	 <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>
	 <1303279470.2756.17.camel@edumazet-laptop>
	 <1303285519.4dae8f0fdf9b1@imp.free.fr>  <4DAE901C.2090809@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: casteyde.christian@free.fr, Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55543 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614Ab1DTIKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 04:10:02 -0400
Received: by wwa36 with SMTP id 36so579827wwa.1
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2011 01:10:01 -0700 (PDT)
In-Reply-To: <4DAE901C.2090809@cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 avril 2011 =C3=A0 10:49 +0300, Pekka Enberg a =C3=A9crit=
 :
> On 4/20/11 10:45 AM, casteyde.christian@free.fr wrote:
> > Indeed I can reproduce each time I boot, however I didn't managed t=
o apply the
> > patch to test it on -rc3 (neither -rc4), only the first hunk passed=
=2E
>=20
> That's odd. Eric?
>=20

I dont know, my patches were linux-2.6 based, and I pull tree very
often ;)

> > I simply boot on this laptop with kmemcheck activated to get the wa=
rning, with
> > vanilla -rc3. I've also tested -rc4 yersterday (without the patch t=
herefore),
> > the warning was not the same (it's a bit later, I will post the dme=
sg output on
> > bugzilla tonight).
>=20
> That's expected. You're unlikely to see the problem in the exact same=
=20
> place across different kernel configs and versions.
>=20

Christian, please send us your .config

Thanks


