From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Remove seq_rtt ptr from clean_rtx_queue args
Date: Mon, 24 Dec 2007 21:56:45 -0800 (PST)
Message-ID: <20071224.215645.262526271.davem@davemloft.net>
References: <Pine.LNX.4.64.0712211617020.7301@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44119
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750757AbXLYF4p convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Dec 2007 00:56:45 -0500
In-Reply-To: <Pine.LNX.4.64.0712211617020.7301@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 21 Dec 2007 16:19:19 +0200 (EET)

> While checking Gavin's patch I noticed that the returned seq_rtt
> is not used by the caller.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Good catch, applied to net-2.6.25

The history of this is that way back when, Vegas used to
use it for RTT calculations, bit it handles that now via
the ->pkts_acked() cong-control method.
