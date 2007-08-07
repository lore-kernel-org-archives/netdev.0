From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue, 7 Aug 2007 11:52:46 +0200
Message-ID: <20070807095246.GB3223@ff.dom.local>
References: <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local> <20070726091254.GA8063@elte.hu> <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com> <20070731132037.GC1046@ff.dom.local> <4bacf17f0708060000n5a00bb77i74adc3b4b28ac42b@mail.gmail.com> <20070806070300.GA4509@elte.hu> <4bacf17f0708070046o14403089v8376a4544f72fec3@mail.gmail.com> <20070807082321.GB2120@ff.dom.local> <4bacf17f0708070237w19d184b3p7f74b53612edb9a6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Marcin =?iso-8859-2?Q?=A6lusarz?= <marcin.slusarz@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4bacf17f0708070237w19d184b3p7f74b53612edb9a6@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 07, 2007 at 11:37:01AM +0200, Marcin =A6lusarz wrote:
> 2007/8/7, Jarek Poplawski <jarkao2@o2.pl>:
> > On Tue, Aug 07, 2007 at 09:46:36AM +0200, Marcin =A6lusarz wrote:
> > > Network card still locks up (tested on 2.6.22.1). I had to upload=
 more
> > > data than usual (~350 MB vs ~1-100 MB) to trigger that bug but it
> > > might be a coincidence...
> >
> > Thanks! It's a good news after all - it would be really strange why
> > this place doesn't hit more people (it seems there is some safety
> > elsewhere for this).
> >
> > BTW: I hope, this previous Thomas' patch with Ingo's warning to res=
end.c
> > (with a warning), had no problems with a similar load?
> I always tested on 500-600 MB "dataset"
>=20
> > PS: Marcin, if you need a break in this testing let us know!
> No, i don't need a break. I'll have more time in next weeks.

Great! So, I'll try to send a patch with _SW_RESEND in a few hours,
if Ingo doesn't prepare something for you.

Thanks,
Jarek P.
