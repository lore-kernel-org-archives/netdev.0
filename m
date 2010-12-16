From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/veth: Fix packet checksumming
Date: Thu, 16 Dec 2010 14:42:37 -0800 (PST)
Message-ID: <20101216.144237.233708334.davem@davemloft.net>
References: <26dfeea6053e4dce108037ecee0fec25b1182937.1292347522.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50227
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751608Ab0LPWmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 17:42:08 -0500
In-Reply-To: <26dfeea6053e4dce108037ecee0fec25b1182937.1292347522.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 14 Dec 2010 23:35:13 +0100 (CET)

> We can't change ip_summed from CHECKSUM_PARTIAL to CHECKSUM_NONE
> or CHECKSUM_UNNECESSARY because checksum in packet's headers is
> not valid and will cause invalid checksum when frame is forwarded.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied to net-2.6, thanks.
