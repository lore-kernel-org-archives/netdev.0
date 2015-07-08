From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,v2] ip_tunnel: fix ipv4 pmtu check to honor inner
 ip header df
Date: Wed, 08 Jul 2015 16:03:33 -0700 (PDT)
Message-ID: <20150708.160333.436760090755596682.davem@davemloft.net>
References: <20150707033906.GF1173@brightrain.aerifal.cx>
	<1436247253-6466-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38202 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752294AbbGHXDe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:03:34 -0400
In-Reply-To: <1436247253-6466-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Tue,  7 Jul 2015 08:34:13 +0300

> Frag needed should be sent only if the inner header asked
> to not fragment. Currently fragmentation is broken if the
> tunnel has df set, but df was not asked in the original
> packet. The tunnel's df needs to be still checked to update
> internally the pmtu cache.
>=20
> Commit 23a3647bc4f93bac broke it, and this commit fixes
> the ipv4 df check back to the way it was.
>=20
> Fixes: 23a3647bc4f93bac ("ip_tunnels: Use skb-len to PMTU check.")
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

Applied and queued up for -stable, thanks.
