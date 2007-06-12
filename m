From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/1] [TCP]: Fix left_out setting during FRTO
Date: Tue, 12 Jun 2007 16:17:52 -0700 (PDT)
Message-ID: <20070612.161752.106483939.davem@davemloft.net>
References: <Pine.LNX.4.64.0706121147020.22843@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51650
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754027AbXFLXRg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 19:17:36 -0400
In-Reply-To: <Pine.LNX.4.64.0706121147020.22843@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 12 Jun 2007 11:50:29 +0300 (EEST)

> Without FRTO, the tcp_try_to_open is never called with
> lost_out > 0 (see tcp_time_to_recover). However, when FRTO is
> enabled, the !tp->lost condition is not used until end of FRTO
> because that way TCP avoids premature entry to fast recovery
> during FRTO.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Thanks for catching this, patch applied.
