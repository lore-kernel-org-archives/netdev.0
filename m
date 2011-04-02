From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 32322] New: Kernel crashes randomly due to unknown reason
Date: Fri, 01 Apr 2011 21:47:55 -0700 (PDT)
Message-ID: <20110401.214755.212694098.davem@davemloft.net>
References: <20110331084530.187c9145@nehalam>
	<alpine.DEB.2.00.1103312212360.9481@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: henrick19777@yahoo.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58182
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750869Ab1DBEsc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Apr 2011 00:48:32 -0400
In-Reply-To: <alpine.DEB.2.00.1103312212360.9481@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 31 Mar 2011 22:37:21 +0300 (EEST)

> [PATCH] tcp: len check is unnecessarily devastating, change to WARN_O=
N
>=20
> All callers are prepared to alloc failures anyway, so this error
> can safely be boomeranged to the callers domain without super
> bad consequences. ...At worst the connection might go into a state
> where each RTO tries to (unsuccessfully) re-fragment with such
> a mis-sized value and eventually dies.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
