From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] f_phonet: fix page offset of first received fragment
Date: Thu, 17 Nov 2011 17:03:35 -0500 (EST)
Message-ID: <20111117.170335.552094082400699219.davem@davemloft.net>
References: <1321534735-9949-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, remi.denis-courmont@nokia.com
To: remi@remlab.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33559 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334Ab1KQWEp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 17:04:45 -0500
In-Reply-To: <1321534735-9949-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi@remlab.net>
Date: Thu, 17 Nov 2011 14:58:55 +0200

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> We pull one byte (the MAC header) from the first fragment before the
> fragment is actually appended. So the socket buffer length is 1, not =
0.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied, thanks.
