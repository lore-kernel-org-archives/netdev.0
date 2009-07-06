From: Andres Freund <andres@anarazel.de>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 ( possibly?caused by netem)
Date: Mon, 6 Jul 2009 19:24:47 +0200
Message-ID: <200907061924.48448.andres@anarazel.de>
References: <200907031326.21822.andres@anarazel.de> <200907061813.29379.andres@anarazel.de> <20090706163106.GA4559@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Joao Correia <joaomiguelcorreia@gmail.com>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754135AbZGFRZA@vger.kernel.org>
In-Reply-To: <20090706163106.GA4559@ami.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 06 July 2009 18:31:06 Jarek Poplawski wrote:
> On Mon, Jul 06, 2009 at 06:13:29PM +0200, Andres Freund wrote:
> > > > Btw, I ran netem with delay for more than 48h on around 80mbit...
> > > > That does  not exclude such a rarely triggered race, but makes it a
> > > > bit more unlikely. (With migration thats around 3sec or so)
> > Sorry once more.
> Andres, the bisection + the above - you did 'the whole lotta work' and
> you shouldn't be sorry at all! ;-)
To be fair I have to admit I did run netem for 48hours for other reasons ;-)
I also ran my modified netem, but all it currently does is adjusing 
delay/jitter by other means, so that should have no influence.
I am trying to produce artificial loss patterns similar to really occuring 
network loss.

I just switched mail client btw ;-)

ATM I have no further ideas except maybe trying different timers or a lower 
timer resolution?

Andres
