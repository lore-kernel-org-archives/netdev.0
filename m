From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [PATCHv4 2/2] memory barrier: adding smp_mb__after_lock
Date: Fri, 3 Jul 2009 09:41:26 +0200
Message-ID: <20090703074126.GB2902@jolsa.lab.eng.brq.redhat.com>
References: <20090702063259.GA3429@jolsa.lab.eng.brq.redhat.com> <20090702063624.GC3429@jolsa.lab.eng.brq.redhat.com> <4A4C5983.7000501@gmail.com> <alpine.DEB.1.10.0907020738020.5194@makko.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58105 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751709AbZGCHl2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jul 2009 03:41:28 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0907020738020.5194@makko.or.mcafeemobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 02, 2009 at 07:39:04AM -0700, Davide Libenzi wrote:
> On Thu, 2 Jul 2009, Eric Dumazet wrote:
>=20
> > Jiri Olsa a =E9crit :
> > > Adding smp_mb__after_lock define to be used as a smp_mb call afte=
r
> > > a lock. =20
> > >=20
> > > Making it nop for x86, since {read|write|spin}_lock() on x86 are=20
> > > full memory barriers.
> > >=20
> > > wbr,
> > > jirka
> > >=20
> > >=20
> > > Signed-off-by: Jiri Olsa <jolsa@redhat.com>
> >=20
> >=20
> > Maybe we should remind that sk_has_helper() is always called
> > right after a call to read_lock() as in :
> >=20
> > 	read_lock(&sk->sk_callback_lock);
> > 	if (sk_has_sleeper(sk))
> > 		wake_up_interruptible_all(sk->sk_sleep);
>=20
> Agreed, that'd be to have it in the source code comment.
>=20
>=20
> - Davide
>=20

ok, I'll add it to the 1/2 part in v5

jirka
