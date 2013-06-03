From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] ipv4: rate limit updating of next hop
 exceptions with same pmtu
Date: Mon, 03 Jun 2013 00:10:02 -0700 (PDT)
Message-ID: <20130603.001002.1688501221299992537.davem@davemloft.net>
References: <20130527.233844.2081972819091665848.davem@davemloft.net>
	<1369723593-5307-1-git-send-email-timo.teras@iki.fi>
	<1369723593-5307-2-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab3FCHKD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 03:10:03 -0400
In-Reply-To: <1369723593-5307-2-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Tue, 28 May 2013 09:46:32 +0300

> The tunnel devices call update_pmtu for each packet sent, this causes
> contention on the fnhe_lock. Ignore the pmtu update if pmtu is not
> actually changed, and there is still plenty of time before the entry
> expires.
>=20
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

Applied.
