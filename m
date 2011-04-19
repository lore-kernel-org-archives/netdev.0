From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: s2io: convert to hw_features
Date: Mon, 18 Apr 2011 23:04:53 -0700 (PDT)
Message-ID: <20110418.230453.115922164.davem@davemloft.net>
References: <20110418233121.1726C13A64@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jdmason@kudzu.us
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60218
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752493Ab1DSGF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 02:05:27 -0400
In-Reply-To: <20110418233121.1726C13A64@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 19 Apr 2011 01:31:20 +0200 (CEST)

> This removes advertising HW_CSUM as driver does not support it.
>=20
> Note: driver advertises TSO6 but not IPV6_CSUM - bug maybe?
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Yes it's probably a bug.  Since, as I understand it, this driver is
in pretty deep maintainence mode the best thing to do is probably
to remove the TSO6 flag.

Applied, thanks.
