From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP] FRTO: remove unnecessary fackets/sacked_out
 recounting
Date: Mon, 07 May 2007 00:47:24 -0700 (PDT)
Message-ID: <20070507.004724.115914377.davem@davemloft.net>
References: <Pine.LNX.4.64.0704211632580.30204@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0705071028400.3607@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47400
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752808AbXEGHrV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 03:47:21 -0400
In-Reply-To: <Pine.LNX.4.64.0705071028400.3607@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 7 May 2007 10:34:33 +0300 (EEST)

> On Sat, 21 Apr 2007, Ilpo J=E4rvinen wrote:
>=20
> > F-RTO does not touch SACKED_ACKED bits at all, so there is no
> > need to recount them in tcp_enter_frto_loss. After removal of
> > the else branch, the nested ifs can be combined.
>=20
> Just in case you come across this, please do not apply it! I noticed =
that=20
> even though it seems very innocent change, it will cause S+L when SAC=
K is=20
> not in use because sacked_out is not reset. I'll provide updated patc=
h for=20
> this later on...

Ok.
