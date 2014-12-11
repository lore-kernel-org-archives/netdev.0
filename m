From: David Miller <davem@davemloft.net>
Subject: Re: [net] gre: fix the inner mac header in nbma gre tunnels xmit
 path
Date: Thu, 11 Dec 2014 14:36:27 -0500 (EST)
Message-ID: <20141211.143627.1516156524809595238.davem@davemloft.net>
References: <CA+mtBx-WsgMRAYDUaPiVaBt43cRx7tb-0hRJ+6Eao8vjd3j8aQ@mail.gmail.com>
	<1418282079-30245-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com,
	alexander.h.duyck@redhat.com
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55897 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783AbaLKTga convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 14:36:30 -0500
In-Reply-To: <1418282079-30245-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Thu, 11 Dec 2014 09:14:39 +0200

> @@ -266,6 +262,7 @@ static netdev_tx_t ipgre_xmit(struct sk_buff *skb=
,
>  		 * to gre header.
>  		 */
>  		skb_pull(skb, tunnel->hlen + sizeof(struct iphdr));
> +		skb_reset_mac_header(mac);

Please explain to me how this compiles, let alone be functionally
tested.
