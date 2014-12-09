From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next 2/2] tcp_cubic: refine Hystart delay threshold
Date: Tue, 9 Dec 2014 13:22:23 -0800
Message-ID: <CAA93jw67K9ECZgOGveEXqZh2_LDuhgHH49OCvT0eMJ+PMFKpuw@mail.gmail.com>
References: <1417738429.22424.29.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141209.145856.1280304544503810169.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>, sangtae.ha@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:59791 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbaLIVWY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 16:22:24 -0500
Received: by mail-oi0-f41.google.com with SMTP id a3so1066011oib.28
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 13:22:23 -0800 (PST)
In-Reply-To: <20141209.145856.1280304544503810169.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 9, 2014 at 11:58 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 04 Dec 2014 16:13:49 -0800
>
>> From: Eric Dumazet <edumazet@google.com>
>>
>> In commit 2b4636a5f8ca ("tcp_cubic: make the delay threshold of HySt=
art
>> less sensitive"), HYSTART_DELAY_MIN was changed to 4 ms.
>>
>> The remaining problem is that using delay_min + (delay_min/16) as th=
e
>> threshold is too sensitive.
>>
>> 6.25 % of variation is too small for rtt above 60 ms, which are not
>> uncommon.
>  ...
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>
> Applied.

Thank you (in a weird way!) for invalidating several weeks worth of
long rtt tests of some aqm and fq variants.

http://snapon.lab.bufferbloat.net/~d/comprehensive.puck/long_rtt_baseli=
ne.png

/me goes off to pull and recompile, and try again.

--=20
Dave T=C3=A4ht

http://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
