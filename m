From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Thu, 5 May 2011 13:40:19 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1105051339310.6821@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <20110418153852.153d3ed3.akpm@linux-foundation.org>  <1303181466.4152.39.camel@edumazet-laptop>  <1303182557.4152.48.camel@edumazet-laptop>  <1303183217.4152.49.camel@edumazet-laptop>
 <alpine.DEB.2.00.1104191210011.17888@router.home>  <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>  <1303279470.2756.17.camel@edumazet-laptop>  <1303285519.4dae8f0fdf9b1@imp.free.fr>  <4DAE901C.2090809@cs.helsinki.fi>
 <1303286998.3186.18.camel@edumazet-laptop>  <1303290464.3186.32.camel@edumazet-laptop>  <1303293765.3186.74.camel@edumazet-laptop>  <alpine.DEB.2.00.1104200904440.8634@router.home>  <1303309591.3186.84.camel@edumazet-laptop>  <alpine.DEB.2.00.1104200942020.9266@router.home>
  <1303311687.3186.100.camel@edumazet-laptop> <1304576296.32152.713.camel@edumazet-laptop> <4DC24239.7050806@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>, casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp108.prem.mail.ac4.yahoo.com ([76.13.13.47]:36660 "HELO
	smtp108.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932073Ab1EESkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 14:40:23 -0400
In-Reply-To: <4DC24239.7050806@cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 5 May 2011, Pekka Enberg wrote:

> > > -#ifdef CONFIG_CMPXCHG_LOCAL
> > > +#ifdef SLUB_USE_CMPXCHG_DOUBLE
> > >   	/*
> > >   	 * Must align to double word boundary for the double cmpxchg
> > > instructions
> > >   	 * to work.
> > >
> >
> >
> > Is anybody taking the patch and sending it upstream ?
>
> Oh, sorry, it got lost in my inbox. I can take care of it.

Combining this one with the patch I sent to remove the #ifdeffery would
make this much simpler.

