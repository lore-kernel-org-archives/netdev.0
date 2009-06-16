From: Rami Rosen <ramirose@gmail.com>
Subject: Re: [PATCH net-next-2.6] udp: remove unused union in udp_skb_cb.
Date: Tue, 16 Jun 2009 12:54:10 +0300
Message-ID: <eb3ff54b0906160254q4ad0e852k611d7f2772afc185@mail.gmail.com>
References: <eb3ff54b0906160150n74fb8984u84a366f5e472b4c3@mail.gmail.com>
	 <20090616.024058.209622628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:63905 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752096AbZFPJyO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 05:54:14 -0400
Received: by ewy6 with SMTP id 6so5832124ewy.37
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2009 02:54:15 -0700 (PDT)
In-Reply-To: <20090616.024058.209622628.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Sorry, I forgot that besides UDP_SKB_CB() also the
IPSKB() macro can access the cb.

>The layer above UDP packet processing used
> IPSKB() and the ipv6 variant (I forget what it's called)

BTW, it is IP6CB() in IPV6

Regards,
Rami Rosen


On Tue, Jun 16, 2009 at 12:40 PM, David Miller<davem@davemloft.net> wro=
te:
> From: Rami Rosen <ramirose@gmail.com>
> Date: Tue, 16 Jun 2009 11:50:11 +0300
>
>> This cleanup patch removes an unused union (header) in udp_skb_cb.
>> (include/net/udp.h)
>
> It is used Rami. =A0The layer above UDP packet processing used
> IPSKB() and the ipv6 variant (I forget what it's called) so
> we have to take care not to write over that layer's recorded
> values in the skb->cb[]
>
