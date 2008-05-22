From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [TCP]: Make prior_ssthresh a u32
Date: Wed, 21 May 2008 17:40:23 -0700 (PDT)
Message-ID: <20080521.174023.73232424.davem@davemloft.net>
References: <Pine.LNX.4.64.0805211534170.16829@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37926
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756997AbYEVAk1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2008 20:40:27 -0400
In-Reply-To: <Pine.LNX.4.64.0805211534170.16829@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 21 May 2008 15:36:08 +0300 (EEST)

> If previous window was above representable values of u16,
> strange things will happen if undo with the truncated value
> is called for. Alternatively, this could be fixed by some
> max trickery but that would limit undoing high-speed undos.
>=20
> Adds 16-bit hole but there isn't anything to fill it with.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.

I'm sure we'll find something to put in that new u16 hole :)
