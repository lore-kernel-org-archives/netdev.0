From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/9] [TCP]: Remove TCPCB_URG & TCPCB_AT_TAIL as
 unnecessary
Date: Mon, 31 Dec 2007 04:50:48 -0800 (PST)
Message-ID: <20071231.045048.133108797.davem@davemloft.net>
References: <11990980772309-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11990980773732-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11990980772445-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37719
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758368AbXLaMut convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2007 07:50:49 -0500
In-Reply-To: <11990980772445-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 31 Dec 2007 12:47:54 +0200

> The snd_up check should be enough. I suspect this has been
> there to provide a minor optimization in clean_rtx_queue which
> used to have a small if (!->sacked) block which could skip
> snd_up check among the other work.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

This looks good, and I agree with your suspicion about what is the
history of this flag.
