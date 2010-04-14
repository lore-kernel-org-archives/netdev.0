From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Wed, 14 Apr 2010 17:20:09 +0200
Message-ID: <1271258409.16881.1701.camel@edumazet-laptop>
References: <1271238738-8386-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:54831 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755653Ab0DNPUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 11:20:17 -0400
Received: by bwz25 with SMTP id 25so297901bwz.28
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 08:20:15 -0700 (PDT)
In-Reply-To: <1271238738-8386-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 avril 2010 =C3=A0 17:52 +0800, Changli Gao a =C3=A9crit =
:
> batch skb dequeueing from softnet input_pkt_queue
>=20
> batch skb dequeueing from softnet input_pkt_queue to reduce potential=
 lock
> contention and irq disabling/enabling.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Adding stop_machine() with no explanation ?

No ack from my previous comments, suggestions, and still same logic ?

Are we supposed to read patch, test it, make some benches, correct bugs=
,
say Amen ?

This is becoming silly, if you ask me.

This is a NACK of this patch, obviously.



