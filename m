From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH tcp-2.6 3/3] [TCP]: Move sack_ok access to obviously
 named funcs & cleanup
Date: Mon, 02 Jul 2007 22:10:09 -0700 (PDT)
Message-ID: <20070702.221009.56977806.davem@davemloft.net>
References: <11819058303890-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11819058313153-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11819058313595-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51051
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751512AbXGCFJt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 01:09:49 -0400
In-Reply-To: <11819058313595-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 15 Jun 2007 14:10:30 +0300

> From: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>
>=20
> Previously code had IsReno/IsFack defined as macros that were
> local to tcp_input.c though sack_ok field has users elsewhere
> too for the same purpose. This changes them to static inlines as
> preferred according the current coding style and unifies the
> access to sack_ok across multiple files. Magic bitops of sack_ok
> for FACK and DSACK are also abstracted to functions with
> appropriate names.
>=20
> Note:
> - One sack_ok =3D 1 remains but that's self explanary, i.e., it
>   enables sack
> - Couple of !IsReno cases are changed to tcp_is_sack
> - There were no users for IsDSack =3D> I dropped it
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Also applied to tcp-2.6, thanks a lot!
