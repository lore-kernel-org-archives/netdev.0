From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] Use sk_mark for routing lookup in more places
Date: Fri, 2 Oct 2009 10:25:13 -0700
Message-ID: <55a4f86e0910021025u7523029av1e4ee917d1fb1ee5@mail.gmail.com>
References: <200910011814.47689.atis@mikrotik.com> <4AC4D90E.3040008@gmail.com>
	 <20091001.151823.263194343.davem@davemloft.net>
	 <4AC58C46.8080408@gmail.com> <4AC598D7.9080900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, atis@mikrotik.com,
	panther@balabit.hu, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:36505 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757739AbZJBRZN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 13:25:13 -0400
Received: by bwz6 with SMTP id 6so1204688bwz.37
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2009 10:25:15 -0700 (PDT)
In-Reply-To: <4AC598D7.9080900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cool!

As I've already pointed out in a post 2 or so weeks ago, we need the
exact same treatment in a ton of places throughout the code (tcp,
ipv6, decnet, etc...).

Maybe it would make more sense to create some constructor-like
functions for the flowi struct?

On Thu, Oct 1, 2009 at 23:08, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
> Eric Dumazet a =C3=A9crit :
>> Here is a followup on this area, thanks.
>>
>> [RFC] af_packet: fill skb->mark at xmit
>>
>> skb->mark may be used by classifiers, so fill it in case user
>> set a SO_MARK option on socket.
>>
>
> Maybe a more generic way to handle this for various protocols
> would be to fill skb->mark in sock_alloc_send_pskb()
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>
