From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] sfc: Fix assignment of ip_summed for pre-allocated
 skbs
Date: Sat, 25 Feb 2012 07:01:16 +0100
Message-ID: <1330149676.2462.28.camel@edumazet-laptop>
References: <1330132277.2397.17.camel@bwh-desktop>
	 <1330132354.2397.18.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:65208 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911Ab2BYGBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Feb 2012 01:01:20 -0500
Received: by wibhm11 with SMTP id hm11so362744wib.19
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2012 22:01:19 -0800 (PST)
In-Reply-To: <1330132354.2397.18.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 25 f=C3=A9vrier 2012 =C3=A0 01:12 +0000, Ben Hutchings a =C3=A9=
crit :
> When pre-allocating skbs for received packets, we set ip_summed =3D
> CHECKSUM_UNNCESSARY.  We used to change it back to CHECKSUM_NONE when
> the received packet had an incorrect checksum or unhandled protocol.
>=20
> Commit bc8acf2c8c3e43fcc192762a9f964b3e9a17748b ('drivers/net: avoid
> some skb->ip_summed initializations') mistakenly replaced the latter
> assignment with a DEBUG-only assertion that ip_summed =3D=3D
> CHECKSUM_NONE.  This assertion is always false, but it seems no-one
> has exercised this code path in a DEBUG build.
>=20
> Fix this by moving our assignment of CHECKSUM_UNNECESSARY into
> efx_rx_packet_gro().
>=20
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---

Ah, I'm sorry I missed this.

Thanks !
