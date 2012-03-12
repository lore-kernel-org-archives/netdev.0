From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: get rid of some pointless casts to sockaddr
Date: Sun, 11 Mar 2012 19:49:04 -0700 (PDT)
Message-ID: <20120311.194904.1190726266951277668.davem@davemloft.net>
References: <1331506310-16613-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43176 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab2CLCtI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 22:49:08 -0400
In-Reply-To: <1331506310-16613-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Sun, 11 Mar 2012 15:51:50 -0700

> From: Maciej =AFenczykowski <maze@google.com>
>=20
> The following 4 functions:
>   move_addr_to_kernel
>   move_addr_to_user
>   verify_iovec
>   verify_compat_iovec
> are always effectively called with a sockaddr_storage.
>=20
> Make this explicit by changing their signature.
>=20
> This removes a large number of casts from sockaddr_storage to sockadd=
r.
>=20
> Signed-off-by: Maciej =AFenczykowski <maze@google.com>

Applied, thanks.
