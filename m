From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [TCP]: Include __tcp_reset_fack_counts to non-__
 version
Date: Tue, 11 Dec 2007 04:17:59 -0800 (PST)
Message-ID: <20071211.041759.119108521.davem@davemloft.net>
References: <11973738391620-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11973738393633-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11973738392955-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52293
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752111AbXLKMSA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 07:18:00 -0500
In-Reply-To: <11973738392955-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 11 Dec 2007 13:50:39 +0200

> This makes flow more obvious in case of short-circuit and
> removes need for prev double pointer & fc recount per queue
> switch.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Looks good.  References to pointers are always ugly and result
in hard to understand code and subtle bugs.

Applied.
