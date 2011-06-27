From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 1/3] be2net: fix netdev_stats_update
Date: Mon, 27 Jun 2011 19:20:41 +0200
Message-ID: <1309195241.2532.79.camel@edumazet-laptop>
References: <4da4117c-a24a-4512-9b79-fbed126e03bc@exht1.ad.emulex.com>
	 <20110627094337.5108b5f6@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sathya Perla <sathya.perla@emulex.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52476 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753084Ab1F0RUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 13:20:45 -0400
Received: by wyg8 with SMTP id 8so1229515wyg.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 10:20:44 -0700 (PDT)
In-Reply-To: <20110627094337.5108b5f6@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 27 juin 2011 =C3=A0 09:43 -0700, Stephen Hemminger a =C3=A9cri=
t :
> On Mon, 27 Jun 2011 12:10:48 +0530
> Sathya Perla <sathya.perla@emulex.com> wrote:
>=20
> > Problem initially reproted and fixed by Eric Dumazet <eric.dumazet@=
gmail.com>
> >=20
> > netdev_stats_update() resets netdev->stats and then accumulates sta=
ts from
> > various rings. This is wrong as stats readers can sometimes catch z=
ero values.
> > Use temporary variables instead for accumulating per-ring values.
> >=20
> > Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
>=20
> Should also use u64_stats_sync to ensure correct rollover or 32 bit S=
MP
> platform.

These are "unsigned long" fields, you dont need u64_stats_sync.




