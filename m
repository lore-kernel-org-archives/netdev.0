From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Wed, 8 Jul 2009 19:47:48 +0200
Message-ID: <20090708174748.GB4650@jolsa.lab.eng.brq.redhat.com>
References: <20090703092438.GE3902@elte.hu> <20090703095659.GA4518@jolsa.lab.eng.brq.redhat.com> <20090703102530.GD32128@elte.hu> <20090703111848.GA10267@jolsa.lab.eng.brq.redhat.com> <20090707101816.GA6619@jolsa.lab.eng.brq.redhat.com> <20090707134601.GB6619@jolsa.lab.eng.brq.redhat.com> <20090707140135.GA5506@Krystal> <4A535EB9.2020406@gmail.com> <20090707145710.GB7124@Krystal> <4A536866.1050906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	davidel@xmailserver.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757630AbZGHRsd@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A536866.1050906@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 07, 2009 at 05:23:18PM +0200, Eric Dumazet wrote:
> Mathieu Desnoyers a =E9crit :
>=20
> > But read_lock + smp_mb__after_lock + read_unlock is not well suited=
 for
> > powerpc, arm, mips and probably others where there is an explicit m=
emory
> > barrier at the end of the read lock primitive.
> >=20
> > One thing that would be efficient for all architectures is to creat=
e a
> > locking primitive that contains the smp_mb, e.g.:
> >=20
> > read_lock_smp_mb()
> >=20
> > which would act as a read_lock which does a full smp_mb after the l=
ock
> > is taken.
> >=20
> > The naming may be a bit odd, better ideas are welcome.
>=20
> I see your point now, thanks for your patience.
>=20
> Jiri, I think your first patch can be applied (including the full smp=
_mb()),
>  then we will optimize both for x86 and other arches, when all=20
> arch maintainers have a chance to change
> "read_lock();smp_mb()" to a faster "read_lock_mb()" or something :)
>

great, I saw you Signed-off the 1/2 part.. could I leave it,
or do I need to resend as a single patch?

jirka
