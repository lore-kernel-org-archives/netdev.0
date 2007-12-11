From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [TCP]: Push fack_count calculation deeper into
 functions
Date: Tue, 11 Dec 2007 04:16:57 -0800 (PST)
Message-ID: <20071211.041657.144576130.davem@davemloft.net>
References: <11973738391620-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11973738393633-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52289
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752076AbXLKMQ6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 07:16:58 -0500
In-Reply-To: <11973738393633-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 11 Dec 2007 13:50:38 +0200

> This shouldn't have a significant impact because the call to
> tcp_sacktag_one is typically made just once per ACK (this
> doesn't hold if there were some ACK losses in between or the
> receiver didn't generate all ACKs that it should have, but
> those are not very likely events to occur).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.

Note that the LRO code will generate stretch ACKs for
in-order normal ACKs, it is something to keep in mind
about this but seems irrelevant for the code you are
touching.
