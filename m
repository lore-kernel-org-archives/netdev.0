From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] [TCP]: Consider GSO while counting reord in sacktag
Date: Sat, 10 Nov 2007 21:21:22 -0800 (PST)
Message-ID: <20071110.212122.56371574.davem@davemloft.net>
References: <11946921623177-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11946921623696-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40703
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751080AbXKKFVX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Nov 2007 00:21:23 -0500
In-Reply-To: <11946921623696-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 10 Nov 2007 12:55:59 +0200

> Reordering detection fails to take account that the reordered
> skb may have pcount larger than 1. In such case the lowest of
> them had the largest reordering, the old formula used the
> highest of them which is pcount - 1 packets less reordered.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks.
