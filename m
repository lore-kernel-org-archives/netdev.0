From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9]: tcp-2.6 patchset
Date: Sun, 27 May 2007 02:11:04 -0700 (PDT)
Message-ID: <20070527.021104.74747736.davem@davemloft.net>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20070526.164418.115928217.davem@davemloft.net>
	<Pine.LNX.4.64.0705271039060.2532@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49135
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751114AbXE0JK6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 May 2007 05:10:58 -0400
In-Reply-To: <Pine.LNX.4.64.0705271039060.2532@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sun, 27 May 2007 10:58:27 +0300 (EEST)

> On Sat, 26 May 2007, David Miller wrote:
>=20
> > From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> > Date: Sat, 26 May 2007 11:35:53 +0300
> >=20
> > > Dave, you could consider applying other than the last one if they
> > > seem ok to you too (you'll need to rebase your tcp-2.6 in that ca=
se
> > > first to apply cleanly those that touch tcp_sync_left_out :-)).
> >=20
> > Absolutely, I'll do the quick rebase of tcp-2.6 and review +
> > applying of your patches (except the last one) over the weekend.
>=20
> While you're in the right context (reviewing patch 8), you could also
> look if tcp_clean_rtx_queue does a right thing when passing a strange=
=20
> pkts_acked to congestion control modules. I wonder if it really shoul=
d=20
> ignore GSO the way it does currently... I read some cc module code an=
d=20
> some was adding it to snd_cwnd_cnt, etc. which is a strong indication=
=20
> that GSO should be considered... Also if the head is GSO skb that is =
not=20
> completely acked, the loop breaks with pkts_acked being zero, I doubt
> that can be correct...=20

I rebased tcp-2.6, applied your patches 1-7 (which I'll comment
a bit on tomorrow) and will likely take a look at these issues
wrt. patch 8 tomorrow.
