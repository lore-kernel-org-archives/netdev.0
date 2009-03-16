From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] tcp: consolidate paws check
Date: Sun, 15 Mar 2009 20:10:38 -0700 (PDT)
Message-ID: <20090315.201038.240269562.davem@davemloft.net>
References: <1237075675426-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12370756753599-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12370756754094-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35129
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752212AbZCPDKw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2009 23:10:52 -0400
In-Reply-To: <12370756754094-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sun, 15 Mar 2009 02:07:51 +0200

> Wow, it was quite tricky to merge that stream of negations
> but I think I finally got it right:
>=20
> check & replace_ts_recent:
> (s32)(rcv_tsval - ts_recent) >=3D 0                  =3D> 0
> (s32)(ts_recent - rcv_tsval) <=3D 0                  =3D> 0
>=20
> discard:
> (s32)(ts_recent - rcv_tsval)  > TCP_PAWS_WINDOW    =3D> 1
> (s32)(ts_recent - rcv_tsval) <=3D TCP_PAWS_WINDOW    =3D> 0
>=20
> I toggled the return values of tcp_paws_check around since
> the old encoding added yet-another negation making tracking
> of truth-values really complicated.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
