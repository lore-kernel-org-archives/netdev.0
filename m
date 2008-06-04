From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 10767] New: Seg Fault Instead of Swapping
Date: Wed, 04 Jun 2008 11:20:15 -0700 (PDT)
Message-ID: <20080604.112015.241905253.davem@davemloft.net>
References: <Pine.LNX.4.64.0805261349510.16829@wrl-59.cs.helsinki.fi>
	<20080603.163518.153888925.davem@davemloft.net>
	<Pine.LNX.4.64.0806040943120.16057@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brian.vowell@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50055
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753300AbYFDSUQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 14:20:16 -0400
In-Reply-To: <Pine.LNX.4.64.0806040943120.16057@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 4 Jun 2008 10:12:04 +0300 (EEST)

> On Tue, 3 Jun 2008, David Miller wrote:
>=20
> > From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> > Date: Mon, 26 May 2008 14:24:33 +0300 (EEST)
> >=20
> > Ilpo, do you want me to apply this to net-2.6?
>=20
> Yes thanks, it is necessary to keep the state consistent (it also exp=
lains=20
> some .22/23 time left_out warn_ons too which were mysterious back the=
n).
> Also -stable (I guess it would be necessary to almost any older stabl=
e
> too though some older ones might want to sync left_out on that same p=
lace=20
> too).
>=20
> It was nice that this path was also triggered while running the TCP=20
> debug patch (I haven't gotten a one in here), otherwise we would neve=
r
> have known though I started to suspect that such path existed once I
> tried to analyze those left_out problems (before it got dropped=20
> altogether), but I just couldn't find the problem because it lies on=20
> such "error path" which was too easy to overlook.

Ok I've add the patch to net-2.6, thanks!

> I also finally have found the cause to the !sacked_out && fackets_out
> trap :-). ...I'll post the fix to that later today to relevant partie=
s.

I'll have a look at this too :-)

Thanks for all of your incredible work on TCP bug fixing!
