From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Wed, 8 Aug 2007 11:30:42 +0200
Message-ID: <20070808093042.GA2426@ff.dom.local>
References: <JMG6AY$2339D4FEA804188F4C6D4F66006A6BB6@xandmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cebbert <cebbert@redhat.com>, mingo <mingo@elte.hu>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>,
	tglx <tglx@linutronix.de>,
	torvalds <torvalds@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	akpm <akpm@linux-foundation.org>, alan <alan@lxorguk.ukuu.org.uk>
To: Jean-Baptiste Vignaud <vignaud@xandmail.fr>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757473AbXHHJaj@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <JMG6AY$2339D4FEA804188F4C6D4F66006A6BB6@xandmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 08, 2007 at 10:59:22AM +0200, Jean-Baptiste Vignaud wrote:
> > Jean-Baptiste: I'm not sure how much of this testing you can afford?
> > If you can spare some time for this and your box isn't for
> > 'production' it could be very precious to diagnose such reproducible
> > bug.
> 
> Well i can continue testing patches for sure.

Great!

> 
> > Then, I'd have a few suggestions (you could choose any of them) like:
> > - trying these last test patches prepared for Marcin, too (but only
> > with kernels 2.6.21 - 2.6.23-rc1),
> 
> I'v patched 2.6.23-rc2 with those patches yesterday evening, and
> launched samba copy.
> Is rc2 ok ?

Yes! Mostly... 2.6.23-rc2 has a "temporary" patch applied, which should
work by itself (at last it works for Marcin). So, it's very good news
it works for you too. But, as a matter of fact the other patches
(I hope you mean these yesterday's two) probably are not used very
much (the last one could do some work but with other irqs).

So, it would be interesting to try them with e.g. 2.6.23-rc1. But not
together (I'd remind that after applying such a patch, make oldconfig,
make and so on plus testing, you can revert it with the same command
you used to patch plus -R option (e.g.: patch -p1 -R < ../patch1.diff),
to save some time on restoring a 'vanilla' kernel version.
The aim of these newer patches is to find why exactly this patch in
-rc2 works...

Cheers,
Jarek P.
