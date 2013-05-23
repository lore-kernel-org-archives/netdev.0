From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ipsec] xfrm: properly handle invalid states as an error
Date: Thu, 23 May 2013 01:20:33 -0700 (PDT)
Message-ID: <20130523.012033.2025528481150126076.davem@davemloft.net>
References: <1369222847-8542-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, roy.qing.li@gmail.com,
	steffen.klassert@secunet.com
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52781 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757451Ab3EWIUe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 04:20:34 -0400
In-Reply-To: <1369222847-8542-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Wed, 22 May 2013 14:40:47 +0300

> The error exit path needs err explicitly set. Otherwise it
> returns success and the only caller, xfrm_output_resume(),
> would oops in skb_dst(skb)->ops derefence as skb_dst(skb) is
> NULL.
>=20
> Bug introduced in commit bb65a9cb (xfrm: removes a superfluous
> check and add a statistic).
>=20
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

Applied and queued up for -stable, thanks.
