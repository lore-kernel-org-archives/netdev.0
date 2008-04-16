From: David Miller <davem@davemloft.net>
Subject: Re: A Linux TCP SACK Question
Date: Wed, 16 Apr 2008 02:35:51 -0700 (PDT)
Message-ID: <20080416.023551.70464279.davem@davemloft.net>
References: <1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
	<20080416.012732.152357000.davem@davemloft.net>
	<Pine.LNX.4.64.0804161203590.17123@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johnwheffner@gmail.com, wenji@fnal.gov, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46046
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752179AbYDPJfy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 05:35:54 -0400
In-Reply-To: <Pine.LNX.4.64.0804161203590.17123@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 16 Apr 2008 12:21:38 +0300 (EEST)

> On Wed, 16 Apr 2008, David Miller wrote:
>=20
> > From: "John Heffner" <johnwheffner@gmail.com>
> > Date: Tue, 15 Apr 2008 15:40:05 -0700
> >=20
> > > Subject: [PATCH] Increase the max_burst threshold from 3 to tp->r=
eordering.
 ...
> > Any objections to my adding this to net-2.6.26?
>=20
> I don't have objections.
>=20
> But I want to note that tp->reordering does not consider the situatio=
n on=20
> that specific ACK because its value might originate a number of segme=
nts=20
> and even RTTs back. I think it could be possible to find a more=20
> appropriate value for max_burst locally to an ACK. ...Though it might=
 be a=20
> bit over-engineered solution. For SACK we calculate similar metric an=
yway=20
> in tcp_clean_rtx_queue to find if tp->reordering needs to be updated =
at=20
> cumulative ACK and for NewReno min(tp->sacked_out, tp->reordering) + =
3
> could perhaps be used (I'm not sure if these would be foolproof in=20
> recovery though).

Right, we can tweak this thing further later.

*beep* *beep*

I've added John's patch to net-2.6.26

