From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: add a truesize parameter to skb_add_rx_frag()
Date: Sat, 24 Mar 2012 02:57:28 -0700
Message-ID: <1332583048.3487.1.camel@edumazet-laptop>
References: <1332508626.4858.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:46942 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000Ab2CXJ5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2012 05:57:32 -0400
Received: by pbcun15 with SMTP id un15so3455893pbc.19
        for <netdev@vger.kernel.org>; Sat, 24 Mar 2012 02:57:31 -0700 (PDT)
In-Reply-To: <1332508626.4858.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 mars 2012 =C3=A0 06:17 -0700, Eric Dumazet a =C3=A9crit =
:
> skb_add_rx_frag() API is misleading.
>=20
> Network skbs built with this helper can use uncharged kernel memory a=
nd
> eventually stress/crash machine in OOM.
>=20
> Add a 'truesize' parameter and then fix drivers in followup patches.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Wey-Yi Guy <wey-yi.w.guy@intel.com>
> ---
>  drivers/net/usb/cdc-phonet.c              |    6 ++++--
>  drivers/net/wireless/iwlegacy/3945.c      |    3 ++-
>  drivers/net/wireless/iwlegacy/4965-mac.c  |    3 ++-
>  drivers/net/wireless/iwlwifi/iwl-agn-rx.c |    2 +-
>  include/linux/skbuff.h                    |    2 +-
>  net/core/skbuff.c                         |    4 ++--
>  6 files changed, 12 insertions(+), 8 deletions(-)

Oh well I missed drivers/usb/gadget/f_phonet.c change, I'll send a v2
