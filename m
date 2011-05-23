From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] caif: Fixes freeze on Link layer removal.
Date: Sun, 22 May 2011 20:13:40 -0400 (EDT)
Message-ID: <20110522.201340.445758096505075998.davem@davemloft.net>
References: <1306099134-12989-1-git-send-email-sjur.brandeland@stericsson.com>
	<1306099134-12989-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754197Ab1EWANs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 20:13:48 -0400
In-Reply-To: <1306099134-12989-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Sun, 22 May 2011 23:18:51 +0200

> CAIF Socket layer - caif_socket.c:
> - Plug mem-leak at reconnect.
> - Always call disconnect to cleanup CAIF stack.
> - Disconnect will always report success.
>=20
> CAIF configuration layer - cfcnfg.c
> - Disconnect must dismantle the caif stack correctly
> - Protect against faulty removals (check on id zero)
>=20
> CAIF mux layer - cfmuxl.c
> - When inserting new service layer in the MUX remove
>   any old entries with the same ID.
> - When removing CAIF Link layer, remove the associated
>   service layers before notifying service layers.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
