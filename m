From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] arp: flush arp cache on IFF_NOARP change
Date: Thu, 23 May 2013 00:01:36 -0700 (PDT)
Message-ID: <20130523.000136.1188829048647539329.davem@davemloft.net>
References: <20130520.134633.448574202175922639.davem@davemloft.net>
	<1369131824-6318-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51700 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485Ab3EWHBr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 03:01:47 -0400
In-Reply-To: <1369131824-6318-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Tue, 21 May 2013 13:23:44 +0300

> IFF_NOARP affects what kind of neighbor entries are created
> (nud NOARP or nud INCOMPLETE). If the flag changes, flush the arp
> cache to refresh all entries.
>=20
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

I agree with Ben that we should have a "orig_priv_flags" or
something like that to implement this, rather than adding
transient state flags to ->priv_flags.
