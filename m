From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next-2.6 1/2] net: introduce __netdev_alloc_skb_ip_align
Date: Tue, 12 Jul 2011 01:12:21 +0200
Message-ID: <CAHXqBFJBt54ksT4D0iee_9GrORzQYkPhmr4ztOH3wxk9rqaJXA@mail.gmail.com>
References: <1310421164.2860.21.camel@edumazet-laptop> <1310425028.2707.12.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:47173 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758345Ab1GKXMm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 19:12:42 -0400
Received: by qwk3 with SMTP id 3so2109748qwk.19
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 16:12:41 -0700 (PDT)
In-Reply-To: <1310425028.2707.12.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/12 Ben Hutchings <bhutchings@solarflare.com>:
> On Mon, 2011-07-11 at 23:52 +0200, Eric Dumazet wrote:
>> RX rings should use GFP_KERNEL allocations if possible, add
>> __netdev_alloc_skb_ip_align() helper to ease this.
> [...]
> When it is possible, other than when starting an interface? =C2=A0RX =
refill
> normally has to be done in NAPI context or at least synchronised with
> NAPI, so GFP_ATOMIC is required. =C2=A0Not sure how much point there =
is in
> making a special case for the initial fill.

Drivers can also refill buffers later, even from separate thread. Ring =
refilling
can be made lockless given proper access ordering is preserved.

Best Regards,
Micha=C5=82 Miros=C5=82aw
