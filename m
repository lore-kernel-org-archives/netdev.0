From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [TCP]: Move prior_in_flight collect to more robust
 place
Date: Wed, 05 Dec 2007 02:21:46 -0800 (PST)
Message-ID: <20071205.022146.189833107.davem@davemloft.net>
References: <11967869303114-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11967869303567-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11967869303709-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52508
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751592AbXLEKVr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 05:21:47 -0500
In-Reply-To: <11967869303709-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue,  4 Dec 2007 18:48:49 +0200

> The previous location is after sacktag processing, which affects
> counters tcp_packets_in_flight depends on. This may manifest as
> wrong behavior if new SACK blocks are present and all is clear
> for call to tcp_cong_avoid, which in the case of
> tcp_reno_cong_avoid bails out early because it thinks that
> TCP is not limited by cwnd.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
