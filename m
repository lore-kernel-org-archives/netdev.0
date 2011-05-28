From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Sat, 28 May 2011 20:04:34 +0200
Message-ID: <20110528180434.GB12530@elte.hu>
References: <4DDEAA3C.7020502@fb.com>
 <1306439246.2543.10.camel@edumazet-laptop>
 <4DDECA9B.8080206@fb.com>
 <1306447292.2543.32.camel@edumazet-laptop>
 <4DDEEBC5.80804@fb.com>
 <1306466831.2543.58.camel@edumazet-laptop>
 <4DDFE4D6.4010000@fb.com>
 <1306526219.2533.3.camel@edumazet-laptop>
 <20110527211419.GA6793@dev1756.snc6.facebook.com>
 <1306561285.2533.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arun Sharma <asharma@fb.com>, David Miller <davem@davemloft.net>,
	Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>,
	Yann Dupont <Yann.Dupont@univ-nantes.fr>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	Thomas Gleixner <tglx@linutronix.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1306561285.2533.9.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > +static inline int atomic_add_unless(atomic_t *v, int a, int u)
> > +{
> > +	return __atomic_add_unless(v, a, u) != u;
> >  }
> >  
> >  #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
> 
> As I said, atomic_add_unless() has several implementations in 
> various arches. You must take care of all, not only x86.

It's a bit sad to see local hacks to generic facilities committed 
upstream like that.

Arun: the x86 bits look good at first sight.

Thanks,

	Ingo
