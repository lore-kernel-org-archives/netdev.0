From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] [TCP]: Congestion control API RTT sampling fix
Date: Fri, 15 Jun 2007 15:11:48 -0700 (PDT)
Message-ID: <20070615.151148.23012001.davem@davemloft.net>
References: <Pine.LNX.4.64.0706151227330.15358@kivilampi-30.cs.helsinki.fi>
	<20070615073255.733f64e3@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39980
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750930AbXFOWL3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2007 18:11:29 -0400
In-Reply-To: <20070615073255.733f64e3@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 15 Jun 2007 07:32:55 -0700

> On Fri, 15 Jun 2007 12:30:12 +0300 (EEST)
> "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:
>=20
> > Commit 164891aadf1721fca4dce473bb0e0998181537c6 broke RTT
> > sampling of congestion control modules. Inaccurate timestamps
> > could be fed to them without providing any way for them to
> > identify such cases. Previously RTT sampler was called only if
> > FLAG_RETRANS_DATA_ACKED was not set filtering inaccurate
> > timestamps nicely. In addition, the new behavior could give an
> > invalid timestamp (zero) to RTT sampler if only skbs with
> > TCPCB_RETRANS were ACKed. This solves both problems.
> >=20
> > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> >
> Yes, let's get this in 2.6.22

Agreed, patch applied, thanks everyone.
