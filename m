From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [TCP] FRTO: RFC4138 allows Nagle override when new
 data must be sent
Date: Mon, 30 Apr 2007 00:42:25 -0700 (PDT)
Message-ID: <20070430.004225.107251032.davem@davemloft.net>
References: <11762834448-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1176283444310-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57501
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423126AbXD3Hm3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 03:42:29 -0400
In-Reply-To: <1176283444310-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 11 Apr 2007 12:24:04 +0300

> This is a corner case where less than MSS sized new data thingie
> is awaiting in the send queue. For F-RTO to work correctly, a
> new data segment must be sent at certain point or F-RTO cannot
> be used at all. RFC4138 allows overriding of Nagle at that
> point.
>=20
> Implementation uses frto_counter states 2 and 3 to distinguish
> when Nagle override is needed.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Also applied, thanks a lot.
