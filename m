From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 7 Aug 2008 14:50:42 +0300
Message-ID: <200808071450.43552.denys@visp.net.lb>
References: <47EA0DAB.7080205@securenet.de> <20080806155306.72039010@tux> <Pine.LNX.4.64.0808070950260.3859@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "=?iso-8859-1?q?D=E2niel?= Fraga" <fragabr@gmail.com>,
	Thomas Jarosch <thomas.jarosch@intra2net.com>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	David Miller <davem@davemloft.net>
To: "Ilpo =?iso-8859-1?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0808070950260.3859@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 07 August 2008, Ilpo J=E4rvinen wrote:
> On Wed, 6 Aug 2008, D=E2niel Fraga wrote:
> > On Thu, 31 Jul 2008 15:47:55 +0200
> >
> > Thomas Jarosch <thomas.jarosch@intra2net.com> wrote:
> > > If your problem is really FRTO related (that what the patch is fo=
r),
> > > you could try to disable FRTO temporarily:
> >
> > 	Hi, the patch helped, but what's the conclusion? Is the problem
> > "solved"? Will this patch be merged in the next kernel? This thread
> > seems to be forgotten.
>
> I was yesterday preparing the patch description by adding some more
> thoughts to it (as if there weren't enough already) but didn't yet se=
nd it
> with new cover (to sort of notify davem).
>
> I give no guarantees about the _next_ kernel but some 2.6.26.y and 2.=
6.27
> is more likely bet.

By the way, i had also problem with frto with local connections, and it=
 was=20
trivial to reproduce. But because of proprioetary(but i have sources)=20
userspace application and specific way of using it - i didn't report to=
=20
maillist. But after patch is ready, add me please in cc, i will test it=
 with=20
me too.

=46or me disabling frto helps to solve problem. With frto i have=20
connections "stalling", if there is trasferred large chunks of data ove=
r=20
loopback. It is complicated way how it works all - but i can try to exp=
lain=20
how everything works, if required.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
