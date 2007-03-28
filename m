From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Rexmit hint must be cleared instead of setting
 it
Date: Wed, 28 Mar 2007 12:14:05 -0700 (PDT)
Message-ID: <20070328.121405.49244759.davem@davemloft.net>
References: <Pine.LNX.4.64.0703281629360.27182@kivilampi-30.cs.helsinki.fi>
	<20070328.120709.35017257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35759
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965705AbXC1TOF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 15:14:05 -0400
In-Reply-To: <20070328.120709.35017257.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: David Miller <davem@davemloft.net>
Date: Wed, 28 Mar 2007 12:07:09 -0700 (PDT)

> From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Wed, 28 Mar 2007 16:31:50 +0300 (EEST)
>=20
> > Stupid error from my side. Even though now that I noticed this,
> > I hoped it would have been an optimization but no, the counter
> > hint is then incorrect. Thus clearing is necessary for now (I
> > still suspect though that this path is never executed).
> >=20
> > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Better safe than sorry :-)
>=20
> We can start putting more aggressive assertions around if you'd
> like to get some invariants like that validated.

In case it's not clear I did apply this patch.
