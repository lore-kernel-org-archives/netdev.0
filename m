From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Sun, 29 May 2011 09:43:03 +0200
Message-ID: <1306654983.30021.10.camel@edumazet-laptop>
References: <4DDECA9B.8080206@fb.com>
	 <1306447292.2543.32.camel@edumazet-laptop> <4DDEEBC5.80804@fb.com>
	 <1306466831.2543.58.camel@edumazet-laptop> <4DDFE4D6.4010000@fb.com>
	 <1306526219.2533.3.camel@edumazet-laptop>
	 <20110527211419.GA6793@dev1756.snc6.facebook.com>
	 <1306561285.2533.9.camel@edumazet-laptop> <20110528180434.GB12530@elte.hu>
	 <1306654424.30021.7.camel@edumazet-laptop> <20110529073840.GB21254@elte.hu>
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
In-Reply-To: <20110529073840.GB21254@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 29 mai 2011 =C3=A0 09:38 +0200, Ingo Molnar a =C3=A9crit :

> Yes and i do this all the time as well, to make life easier for the=20
> stable team.
>=20
> What wasnt fine was to not follow up the backportable hack with the=20
> proper patch though. Or did you plan to do that yourself if Arun=20
> fails to complete the generic variant? (in which case my remark is=20
> moot)
>=20

I am currently working on seqlock.h split into seqcount.h and seqlock.h=
,
because I really need this split, but can take care of this work too, n=
o
problem :

I asked Arun if he wanted to make this himself, because initial idea wa=
s
coming from him, not because I did not want to make it ;)
