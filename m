From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: ip_tunnels: disable dst cache for nbma gre
 tunnels
Date: Thu, 15 May 2014 23:28:03 -0400 (EDT)
Message-ID: <20140515.232803.1761803846594043624.davem@davemloft.net>
References: <20140424151647.2a917ff1@vostro>
	<1400142917-1849-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com, edumazet@google.com
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38928 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716AbaEPD2E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 23:28:04 -0400
In-Reply-To: <1400142917-1849-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Thu, 15 May 2014 11:35:17 +0300

> The connected check fails to check for ip_gre nbma mode tunnels
> properly. ip_gre creates temporary tnl_params with daddr specified
> to pass-in the actual target on per-packet basis from neighbor
> layer. Detect these tunnels by inspecting the actual tunnel
> configuration instead.
>=20
> Fixes: 7d442fab0a67 ("ipv4: Cache dst in tunnels")
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> ---
> Should go to 3.14-stable too.

Good catch.

Applied and queued up for -stable, thank you.
