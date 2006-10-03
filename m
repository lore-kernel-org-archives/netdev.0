From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] Revert [NET_SCHED]: HTB: fix incorrect use of RB_EMPTY_NODE
Date: Tue, 3 Oct 2006 09:27:55 +0200
Message-ID: <20061003072755.GA1652@ff.dom.local>
References: <20061002102447.GA2936@ff.dom.local> <200610021649.39580.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S\. Miller" <davem@davemloft.net>, axboe@suse.de,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:10894 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S965382AbWJCHX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 03:23:26 -0400
To: Ismail Donmez <ismail@pardus.org.tr>
Content-Disposition: inline
In-Reply-To: <200610021649.39580.ismail@pardus.org.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 02, 2006 at 04:49:38PM +0300, Ismail Donmez wrote:
> 02 Eki 2006 Pts 13:24 tarihinde, Jarek Poplawski =BAunlar?? yazm??=BA=
t??:=20
> > On 30-09-2006 21:23, Ismail Donmez wrote:
> > > Hi,
> > >
> > > With commit 10fd48f2376db52f08bf0420d2c4f580e39269e1 [1] ,  RB_EM=
PTY_NODE
> > > changed behaviour so it returns false when the node is empty as e=
xpected.
> >
> > ...
> >
> > > -	if (!RB_EMPTY_NODE(rb)) {
> > > +	if (RB_EMPTY_NODE(rb)) {
> >
> > Maybe you have some kind of agreement with Jens Axboe but I
> > can't understand current way of kernel cooperation:
> > he changes some global behavior to the opposite and fixes
> > his code in three places but can't fix it in the fourth place
> > where it's used? Isn't it both trivial and automatic kind
> > of patch?
>=20
> I don't know if Jens will going to fix other occurrences but the sch_=
htb.c fix=20
> was recent and Jens'  commit got my attention hence the patch.

As a matter of fact this kind of cooperation has also many pluses:
developers have to be more vigilant, read about other's work,
more people are engaged and last but not least there is this
infallible akpm reminding subsystem...

Best regards,

Jarek P.=20
