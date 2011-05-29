From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Sun, 29 May 2011 09:33:44 +0200
Message-ID: <1306654424.30021.7.camel@edumazet-laptop>
References: <4DDEAA3C.7020502@fb.com>
	 <1306439246.2543.10.camel@edumazet-laptop> <4DDECA9B.8080206@fb.com>
	 <1306447292.2543.32.camel@edumazet-laptop> <4DDEEBC5.80804@fb.com>
	 <1306466831.2543.58.camel@edumazet-laptop> <4DDFE4D6.4010000@fb.com>
	 <1306526219.2533.3.camel@edumazet-laptop>
	 <20110527211419.GA6793@dev1756.snc6.facebook.com>
	 <1306561285.2533.9.camel@edumazet-laptop>  <20110528180434.GB12530@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arun Sharma <asharma@fb.com>, David Miller <davem@davemloft.net>,
	Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>,
	Yann Dupont <Yann.Dupont@univ-nantes.fr>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	Thomas Gleixner <tglx@linutronix.de>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110528180434.GB12530@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 28 mai 2011 =C3=A0 20:04 +0200, Ingo Molnar a =C3=A9crit :
> * Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > > +static inline int atomic_add_unless(atomic_t *v, int a, int u)
> > > +{
> > > +	return __atomic_add_unless(v, a, u) !=3D u;
> > >  }
> > > =20
> > >  #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
> >=20
> > As I said, atomic_add_unless() has several implementations in=20
> > various arches. You must take care of all, not only x86.
>=20
> It's a bit sad to see local hacks to generic facilities committed=20
> upstream like that.
>=20

Again, its a stable candidate patch, on a file that had many changes in
recent kernels.

I felt this was the right thing to do, to ease stable teams work.

Its not like there is an urgent need for this atomic_add_unless_return(=
)
thing that we have to worry right now.
