From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/9] [TCP]: Dropped unnecessary skb/sacked accessing in
 reneging
Date: Mon, 31 Dec 2007 04:49:29 -0800 (PST)
Message-ID: <20071231.044929.46765791.davem@davemloft.net>
References: <11990980771495-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11990980772309-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11990980773732-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36623
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758713AbXLaMta convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2007 07:49:30 -0500
In-Reply-To: <11990980773732-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 31 Dec 2007 12:47:53 +0200

> SACK reneging can be precalculated to a FLAG in clean_rtx_queue
> which has the right skb looked up. This will help a bit in
> future because skb->sacked access will be changed eventually,
> changing it already won't hurt any.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
