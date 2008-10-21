From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: two other cases Re: [Bug 11721] after upgrade to 2.6.27 i
	cannot navigate
Date: Tue, 21 Oct 2008 11:12:27 +0000
Message-ID: <20081021111227.GE4715@ff.dom.local>
References: <20081021090002.21e64151@topolino> <Pine.LNX.4.64.0810211200170.7072@wrl-59.cs.helsinki.fi> <20081021100923.GD4715@ff.dom.local> <Pine.LNX.4.64.0810211333290.7072@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Aldo Maggi <sentiniate@tiscali.it>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:9022 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723AbYJULMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 07:12:34 -0400
Received: by ik-out-1112.google.com with SMTP id c30so1519692ika.5
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2008 04:12:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0810211333290.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 21, 2008 at 01:51:10PM +0300, Ilpo J=E4rvinen wrote:
> On Tue, 21 Oct 2008, Jarek Poplawski wrote:
>=20
> > On Tue, Oct 21, 2008 at 12:36:33PM +0300, Ilpo J=E4rvinen wrote:
> > ...
> > > Can you try this another debug patch below (on 2.6.27.2 is fine).=
 It moves=20
> > > the mss to the last position but should keep timestamps in place =
by making=20
> > > wscale as first option. It is well possible that you won't get it=
 working=20
> > > at all except with all ts,sack and wscale set to 0 (the most like=
ly=20
> > > result). Please try with all wscale,sack,ts combinations (no need=
 to=20
> > > provide dumps, just working/not working per case)... This should=20
> > > tell us for quite high certaintity what is the actual option whic=
h is=20
> > > causing this (would it not be the mss-at-beginning which is the m=
ost=20
> > > likely cause), [...]
> >=20
> > I'd like to remind it seems to work with only sack off, so mss afte=
r
> > ts. If so, my suspicion would be around rfc's/options' dating?
>=20
> Thanks, I missed that case... there are so many cases already... :-)
> ...I'm not sure we'll find some very obvious reason for this, rfc dat=
ing=20
> probably has very little to do here.
>=20
> I still think that putting an alternative option in front is useful t=
est=20
> (though my initial mss-at-beginning thought wasn't bullet-proof) but=20
> maybe we could skip all those alternative settings of wscale,sack,ts =
and=20
> have them just all enabled.

I agree with you, but when this test with all options enabled fails
(?!), IMHO disabling sack only could be enough to get it working
again.

Jarek P.
