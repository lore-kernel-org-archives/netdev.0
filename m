From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] net: Make it easier to parse /proc/net/dev contents.
Date: Wed, 06 Jan 2010 06:57:17 +0100
Message-ID: <4B44263D.20604@gmail.com>
References: <20100105155052.13309.1197.stgit@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50666 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab0AFF5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 00:57:22 -0500
In-Reply-To: <20100105155052.13309.1197.stgit@firesoul.comx.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/01/2010 16:50, Jesper Dangaard Brouer a =C3=A9crit :
> The contents of /proc/net/dev is annoying to parse, because
> it changes whether there is a space after the "ethX:" or not.
> It depends upon the size of the "Receive bytes" counter,
> if the number is below 7 digits, then there is whitespaces
> else if the number is 8 digits or above there is no space
> between the ":" and the number.
>=20
> This patch changes the output to assure there is always a space
> between the ":" and the number.  Given that all existing userspace
> application already need to handle the whitespaces, I see
> no breakage of existing tools.
>=20
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

