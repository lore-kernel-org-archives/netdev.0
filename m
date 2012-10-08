From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.4.1 and 3.5-rc1 Packet lost at 250Mb/s
Date: Mon, 08 Oct 2012 14:13:26 +0200
Message-ID: <1349698406.21172.3168.camel@edumazet-glaptop>
References: <409ac8b30a6994028562e1a159ac60aa@justnet.pl>
	 <1349677373.21172.2756.camel@edumazet-glaptop>
	 <9819d6943a7cfddfc8fa49217aa4842e@justnet.pl>
	 <1349689640.21172.3008.camel@edumazet-glaptop>
	 <80bb011e8f1289218087633fd7b115ea@justnet.pl>  <5072C063.6000302@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: adam.niescierowicz@justnet.pl, Netdev <netdev@vger.kernel.org>
To: Andre Tomt <andre@tomt.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63459 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669Ab2JHMNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 08:13:31 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1993458bkc.19
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2012 05:13:30 -0700 (PDT)
In-Reply-To: <5072C063.6000302@tomt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-08 at 14:00 +0200, Andre Tomt wrote:
> On 08. okt. 2012 12:49, Nie=C5=9Bcierowicz Adam wrote:
> > W dniu 08.10.2012 11:47, Eric Dumazet napisa=C5=82(a):
> >> Anyway you dont say where are drops, (ifconfig give us very few dr=
ops)
> >
> > you can see no losses(drop), but a temporary decline in traffic on =
the
> > interface to 0kb/s
>=20
> This sounds very familiar, could it be something similar to:
> http://marc.info/?l=3Dlinux-netdev&m=3D134594936016796&w=3D3
>=20
> The chip seems to be of the same family (though not model)

Yes, but Adam says 3.4.1 already has a problem, while
commit 2cb7a9cc008c25dc03314de563c00c107b3e5432 is in 3.5 only.

Since Adam uses Intel e1000e, it could be the BQL related problem.

(Not sure if Intel guys finally fixed the problem, if not, its really
insane)

http://patchwork.ozlabs.org/patch/163298/
