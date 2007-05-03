From: David Miller <davem@davemloft.net>
Subject: Re: kernel BUG at include/net/tcp.h:739
Date: Thu, 03 May 2007 03:31:13 -0700 (PDT)
Message-ID: <20070503.033113.25133545.davem@davemloft.net>
References: <4638F14E.6000803@googlemail.com>
	<Pine.LNX.4.64.0705030841140.3607@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: michal.k.k.piotrowski@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60861
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161820AbXECKbM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 06:31:12 -0400
In-Reply-To: <Pine.LNX.4.64.0705030841140.3607@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 3 May 2007 09:51:36 +0300 (EEST)

> [PATCH] [TCP]: Use S+L catcher only with SACK for now
>=20
> TCP has a transitional state when SACK is not in use during
> which this invariant is temporarily broken. Without SACK,
> tcp_clean_rtx_queue does not decrement sacked_out. Therefore
> calls to tcp_sync_left_out before sacked_out is again
> corrected by tcp_fastretrans_alert can trigger this trap as
> sacked_out still has couple of segments that are already out
> of window.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

It would be nice to fix non-SACK as you say, but this is good
enough for now.
