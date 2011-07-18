From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 af-packet 1/2] Enhance af-packet to provide
 (near zero)lossless packet capture functionality.
Date: Mon, 18 Jul 2011 08:38:34 +0200
Message-ID: <1310971114.2509.25.camel@edumazet-laptop>
References: <1310959610-1688-1-git-send-email-loke.chetan@gmail.com>
	 <1310959610-1688-2-git-send-email-loke.chetan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Chetan Loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43113 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab1GRGii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 02:38:38 -0400
Received: by wyg8 with SMTP id 8so1856962wyg.19
        for <netdev@vger.kernel.org>; Sun, 17 Jul 2011 23:38:37 -0700 (PDT)
In-Reply-To: <1310959610-1688-2-git-send-email-loke.chetan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 17 juillet 2011 =C3=A0 23:26 -0400, Chetan Loke a =C3=A9cri=
t :
> Signed-off-by: Chetan Loke <loke.chetan@gmail.com>
> ---
>  include/linux/if_packet.h |  125 +++++++++++++++++++++++++++++++++++=
++++++++++
>  1 files changed, 125 insertions(+), 0 deletions(-)

> =20
> +struct tpacket3_hdr {
> +	__u32		tp_status;
> +	__u32		tp_next_offset;
> +	__u32		tp_len;
> +	__u32		tp_snaplen;
> +	__u16		tp_mac;
> +	__u16		tp_net;
> +	__u32		tp_sec;
> +	__u32		tp_nsec;
> +	__u32		tp_rxhash;
> +	__u16		tp_vlan_tci;
> +	__u16		tp_padding;
> +	__u32		tp_next_offset;
> +};

Srange, I see tp_next_offset twice in tpacket3_hdr ?


