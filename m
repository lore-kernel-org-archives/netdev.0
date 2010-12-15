From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 5/5 v2] net: add old_queue_mapping into skb->cb
Date: Wed, 15 Dec 2010 15:41:44 +0800
Message-ID: <AANLkTi=TuZNTXTBxmLqu0yyF=f0xM3CQyr_stRHerv6r@mail.gmail.com>
References: <1292390636-3156-1-git-send-email-xiaosuo@gmail.com> <1292397202.2377.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:54849 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289Ab0LOHmG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 02:42:06 -0500
Received: by fxm18 with SMTP id 18so1699621fxm.2
        for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:42:04 -0800 (PST)
In-Reply-To: <1292397202.2377.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 15, 2010 at 3:13 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
> This is really ugly and error prone.
>
> Could you just use a more normal way to express this ?
>
>
> struct ifb_save_fields_cb {
> =A0 =A0 =A0 =A0u16 queue_mapping;
> };
>
> struct napi_gro_cb {
> =A0 =A0 =A0 =A0struct ifb_save_fields_cb ifb_cb; /* needed by ifb, mu=
st be first */
> =A0 =A0 =A0 =A0...
> }
>
>
> struct qdisc_skb_cb {
> =A0 =A0 =A0 =A0struct ifb_save_fields_cb ifb_cb; /* needed by ifb, mu=
st be first */
> =A0 =A0 =A0 =A0unsigned int =A0 =A0pkt_len;
> };
>

It seems a better way. I'll update netem_skb_cb too. Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
