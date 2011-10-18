From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next] stmmac: limit max_mtu in case of 4KiB and use
 __netdev_alloc_skb (V2)
Date: Tue, 18 Oct 2011 14:26:10 +0200
Message-ID: <1318940770.2657.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318932085-14927-9-git-send-email-peppe.cavallaro@st.com>
	 <1318937995-14228-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43339 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754706Ab1JRMZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 08:25:50 -0400
Received: by wyg36 with SMTP id 36so522196wyg.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 05:25:49 -0700 (PDT)
In-Reply-To: <1318937995-14228-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 octobre 2011 =C3=A0 13:39 +0200, Giuseppe CAVALLARO a =C3=A9=
crit :
> Problem using big mtu around 4096 bytes is you end allocating (4096
> +NET_SKB_PAD + NET_IP_ALIGN + sizeof(struct skb_shared_info) bytes ->
> 8192 bytes : order-1 pages
>=20
> It's better to limit the mtu to SKB_MAX_HEAD(NET_SKB_PAD),
> to have no more than one page per skb.
>=20
> Also the patch changes the netdev_alloc_skb_ip_align() done in
> init_dma_desc_rings() and uses a variant allowing GFP_KERNEL allocati=
ons
> allowing the driver to load even in case of memory pressure.
>=20
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
>=20

Seems good, thanks :)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
