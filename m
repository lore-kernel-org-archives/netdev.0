From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.17-mm4
Date: Fri, 30 Jun 2006 11:50:00 +0200
Message-ID: <20060630095000.GB14603@elte.hu>
References: <20060629013643.4b47e8bd.akpm@osdl.org> <6bffcb0e0606291339s69a16bc5ie108c0b8d4e29ed6@mail.gmail.com> <20060629204330.GC13619@redhat.com> <20060629210950.GA300@elte.hu> <20060629230517.GA18838@elte.hu> <1151662073.31392.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:16341 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S932418AbWF3Jyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 05:54:49 -0400
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Content-Disposition: inline
In-Reply-To: <1151662073.31392.4.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> Ar Gwe, 2006-06-30 am 01:05 +0200, ysgrifennodd Ingo Molnar:
> > it does things like:
> > 
> >         static const unsigned long qd_port[2] = { 0x30, 0xB0 };
> >         static const unsigned long ide_port[2] = { 0x170, 0x1F0 };
> > 
> >         [...]
> >                 unsigned long port = qd_port[i];
> >         [...]
> >                         r = inb_p(port);
> >                         outb_p(0x19, port);
> >                         res = inb_p(port);
> >                         outb_p(r, port);
> > 
> > so it reads/writes port 0x30 and 0xb0. Are those used by something else 
> > on modern hardware?
> 
> Not especially. Perhaps the best thing to do here would be to make qdi 
> compiled into the kernel (as opposed to modular) only do so if 
> "probe_qdi=1" or similar is set.

ok. Is that the standard way of dealing with potentially intrusive 
probes?

	Ingo
