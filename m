From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/10] tcp: Make shifting not clear the hints
Date: Mon, 24 Nov 2008 21:27:03 -0800 (PST)
Message-ID: <20081124.212703.153289559.davem@davemloft.net>
References: <1227536527-29713-6-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-7-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-8-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44722
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750861AbYKYF1D convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 00:27:03 -0500
In-Reply-To: <1227536527-29713-8-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 24 Nov 2008 16:22:04 +0200

> The earlier version was just very basic one which is "playing
> safe" by always clearing the hints. However, clearing of a hint
> is extremely costly operation with large windows, so it must be
> avoided at all cost whenever possible, there is a way with
> shifting too achieve not-clearing.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
