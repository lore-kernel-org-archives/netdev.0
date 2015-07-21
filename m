From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] inet: frags: fix defragmented packet's IP header for af_packet
Date: Tue, 21 Jul 2015 09:29:15 +0200
Message-ID: <CANn89iJxCt0UJAHbw-OdTdFm8WoWUN1fzkK9aDWgQxipJkv=Ew@mail.gmail.com>
References: <1437036881-708-1-git-send-email-edjee@google.com>
	<20150720.203119.344614621480451223.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Edward Jee <edjee@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Jerry Chu <hkchu@google.com>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:35875 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbbGUH3R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 03:29:17 -0400
Received: by wgbcc4 with SMTP id cc4so55321733wgb.3
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 00:29:16 -0700 (PDT)
In-Reply-To: <20150720.203119.344614621480451223.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This doesn't compile.
>
> net/ipv4/ip_fragment.c: In function =E2=80=98ip_frag_reasm=E2=80=99:
> net/ipv4/ip_fragment.c:644:23: error: =E2=80=98skb=E2=80=99 undeclare=
d (first use in this function)
>   ip_send_check(ip_hdr(skb));

This was meant to be
  ip_send_check(iph);

Sorry, will send a v2
