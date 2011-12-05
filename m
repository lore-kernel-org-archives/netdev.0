From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 4/4] caif: Stash away hijacked skb
 destructor and call it later
Date: Mon, 05 Dec 2011 18:46:32 -0500 (EST)
Message-ID: <20111205.184632.1180172565507013728.davem@davemloft.net>
References: <1323033775-3496-1-git-send-email-sjur.brandeland@stericsson.com>
	<1323033775-3496-4-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, alexey.orishko@stericsson.com,
	eric.dumazet@gmail.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932481Ab1LEXqi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 18:46:38 -0500
In-Reply-To: <1323033775-3496-4-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Sun,  4 Dec 2011 22:22:55 +0100

> This patch adds functionality for avoiding orphaning SKB too early.
> The original skb is stashed away and the original destructor is calle=
d
> from the hi-jacked flow-on callback. If CAIF interface goes down and =
a
> hi-jacked SKB exists, the original skb->destructor is restored.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
