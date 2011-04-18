From: Jon Mason <jon.mason@myri.com>
Subject: Re: [PATCH] net: myri10ge: convert to hw_features
Date: Mon, 18 Apr 2011 09:24:17 -0500
Message-ID: <20110418142413.GA1937@myri.com>
References: <20110415145050.0D65C13A66@rere.qmqm.pl>
 <20110415182922.GA2458@myri.com>
 <20110417.233053.70188684.davem@davemloft.net>
 <20110418110347.GA18324@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gallatin@myri.com, brice@myri.com
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1970 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751290Ab1DROZY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 10:25:24 -0400
Content-Disposition: inline
In-Reply-To: <20110418110347.GA18324@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2011 at 01:03:47PM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
> On Sun, Apr 17, 2011 at 11:30:53PM -0700, David Miller wrote:
> > From: Jon Mason <jon.mason@myri.com>
> > Date: Fri, 15 Apr 2011 13:29:22 -0500
> >=20
> > > On Fri, Apr 15, 2011 at 04:50:50PM +0200, Micha=C5=82 Miros=C5=82=
aw wrote:
> > >> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.p=
l>

Acked-by: Jon Mason <jon.mason@myri.com>

> > >> ---
> > >>  drivers/net/myri10ge/myri10ge.c |   66 +++++++-----------------=
--------------
> > >>  1 files changed, 12 insertions(+), 54 deletions(-)
> > >>=20
> > >> diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri1=
0ge/myri10ge.c
> > >> index 1446de5..a48eb92 100644
> > >> --- a/drivers/net/myri10ge/myri10ge.c
> > >> +++ b/drivers/net/myri10ge/myri10ge.c
> > >> @@ -205,7 +205,6 @@ struct myri10ge_priv {
> > >>  	int tx_boundary;	/* boundary transmits cannot cross */
> > >>  	int num_slices;
> > >>  	int running;		/* running?             */
> > >> -	int csum_flag;		/* rx_csums?            */
> > > Get rid of MXGEFW_FLAGS_CKSUM in drivers/net/myri10ge/myri10ge_mc=
p.h,
> > > as this was the only thing using it.
> >  ...
> > > ethtool_op_set_tso does not support TSO6.  This would remove the
> > > enable/disable of that feature.
> > Micha=C5=82 please fix these issues and resubmit this patch, thanks=
!
>=20
> There are no issues. MXGEFW_FLAGS_CKSUM is used elsewhere in the driv=
er
> and TSO6 is handled by masking netdev->hw_features at devinit time.
>=20
> BTW, ethtool_op_set_tso() is not used at all in new offload changing =
scheme.
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw
>=20
