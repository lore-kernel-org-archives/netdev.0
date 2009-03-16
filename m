From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] tcp: don't check mtu probe completion in the loop
Date: Sun, 15 Mar 2009 20:10:46 -0700 (PDT)
Message-ID: <20090315.201046.05249568.davem@davemloft.net>
References: <12370756753599-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12370756754094-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12370756752410-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35132
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752847AbZCPDK7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2009 23:10:59 -0400
In-Reply-To: <12370756752410-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sun, 15 Mar 2009 02:07:52 +0200

> It seems that no variables clash such that we couldn't do
> the check just once later on. Therefore move it.
>=20
> Also kill dead obvious comment, dead argument and add
> unlikely since this mtu probe does not happen too often.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
