From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/10] tcp: more aggressive skipping
Date: Mon, 24 Nov 2008 21:12:34 -0800 (PST)
Message-ID: <20081124.211234.241300174.davem@davemloft.net>
References: <1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40901
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750861AbYKYFMf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 00:12:35 -0500
In-Reply-To: <1227536527-29713-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 24 Nov 2008 16:22:00 +0200

> I knew already when rewriting the sacktag that this condition
> was too conservative, change it now since it prevent lot of
> useless work (especially in the sack shifter decision code
> that is being added by a later patch). This shouldn't change
> anything really, just save some processing regardless of the
> shifter.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
