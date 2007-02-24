From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Correct reordering detection change (no FRTO
 case)
Date: Fri, 23 Feb 2007 16:22:40 -0800 (PST)
Message-ID: <20070223.162240.41636216.davem@davemloft.net>
References: <Pine.LNX.4.64.0702231802140.19465@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50331
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933276AbXBXAWm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 19:22:42 -0500
In-Reply-To: <Pine.LNX.4.64.0702231802140.19465@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 23 Feb 2007 18:09:10 +0200 (EET)

> The reordering detection must work also when FRTO has not been
> used at all which was the original intention of mine, just the
> expression of the idea was flawed.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thank you.

I was specifically looking for logic errors like this, where
non-FRTO was unintentionally changed, but I missed this one.
Good thing you caught it :)
