From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6] natsemi.c NAPI
Date: 28 Sep 2004 06:39:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096367984.8659.149.camel@jzny.localdomain>
References: <20040919163642.GC1307@sunbeam.de.gnumonks.org>
	 <4155D781.8050700@colorfullife.com>
	 <20040927081411.GC3236@sunbeam.de.gnumonks.org>
	 <1096343829.8660.107.camel@jzny.localdomain>
	 <4158E74C.7030709@colorfullife.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <4158E74C.7030709@colorfullife.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-28 at 00:23, Manfred Spraul wrote:
> jamal wrote:
[..]
> >Does this mean that the interupt clears when read?
> >Why would reading a NIC register clear a soundcard interupt?
> >
> >  
> >
> No, of course not. But each soundcard interrupt would cause a 
> netif_rx_schedule, with the following callback from tasklet context. 
> IMHO the overhead of that operation is too large. Additionally it breaks 
> the stuck irq detection.

Ok, In such a case it is advised that a e1000 style NAPI is used
(as opposed to the tulip varinat).
Sorry, I should actually read the code first - I ma hoping i am in
context here.

cheers,
jamal
