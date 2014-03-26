From: =?utf-8?Q?=C3=89meric?= Vigier
	<emeric.vigier@savoirfairelinux.com>
Subject: Re: powerpc: net: gianfar ethernet broken on linux-3.10.29?
Date: Wed, 26 Mar 2014 10:04:15 -0400 (EDT)
Message-ID: <259837795.35930.1395842655728.JavaMail.root@mail>
References: <5332CFF1.5080402@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Romeo Cane (EXT-Other PT/Amadora)" <romeo.cane.ext@coriant.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:59751 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755453AbaCZOER convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 10:04:17 -0400
In-Reply-To: <5332CFF1.5080402@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Mail original -----
> On 3/25/2014 9:26 PM, =C3=89meric Vigier wrote:
> > Hi guys,
> >
> > I work on a Freescale MPC8347 custom board. I ported
> > u-boot-v2014.01 on it. My config is attached.
> > I ported linux-3.2.52 (long-term). DTS is attached.
> >
> [...]
> >
> > Do you guys see what could be wrong in my config?
> > Or what has changed in linux-3.{4,6,8,10} that could break my
> > ethernet?
> >
> > thanks,
> > Emeric
> >
>=20
> Hi Emeric,
>=20
> Thanks for the detailed logs.
> You may refer to Romeo's issue:
> http://permalink.gmane.org/gmane.linux.network/309587

Hi Claudiu,

This is it. It seems I haven't search enough on the web.

>=20
> There's this stable fix for the (older) TSEC controllers:
> commit 5eaedf31319d5f80eaaee1eec8dd18c0b452f0d1
> ("gianfar: Add backwards compatible Single Queue mode polling")

I cherry-picked it on 3.10.29 and it makes the job!

>=20
> that for some reason was not included in kernel 3.10
> (but it was included in kernel 3.11).
>=20
> Hi David,
> Can we have this gianfar fix included in kernel 3.10 as well?
> Is there anything I can do to help with this?

I second this. Thanks Claudiu!

>=20
> Thanks and regards,
> Claudiu
>=20
>=20
>
