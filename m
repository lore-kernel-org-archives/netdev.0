From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: be more strict before accepting ECN negociation
Date: Fri, 4 May 2012 11:54:09 -0400
Message-ID: <CADVnQy=ShWzLOMOhCV5=Me9P4QSCkHK0RQciLXME30B=JWaZkQ@mail.gmail.com>
References: <1336144442.3752.348.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Perry Lorier <perryl@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>,
	Wilmer van der Gaast <wilmer@google.com>,
	=?ISO-8859-1?Q?Dave_T=E4ht?= <dave.taht@bufferbloat.net>,
	Ankur Jain <jankur@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:40734 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751182Ab2EDPyK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 11:54:10 -0400
Received: by ghrr11 with SMTP id r11so2904819ghr.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 08:54:09 -0700 (PDT)
In-Reply-To: <1336144442.3752.348.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 4, 2012 at 11:14 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> It appears some networks play bad games with the two bits reserved fo=
r
> ECN. This can trigger false congestion notifications and very slow
> transferts.
>
> Since RFC 3168 (6.1.1) forbids SYN packets to carry CT bits, we can
> disable TCP ECN negociation if it happens we receive mangled CT bits =
in
> the SYN packet.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Perry Lorier <perryl@google.com>
> Cc: Matt Mathis <mattmathis@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Wilmer van der Gaast <wilmer@google.com>
> Cc: Ankur Jain <jankur@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Dave T=E4ht <dave.taht@bufferbloat.net>
> ---
> =A0include/net/tcp.h =A0 | =A0 23 ++++++++++++++++-------
> =A0net/ipv4/tcp_ipv4.c | =A0 =A02 +-
> =A0net/ipv6/tcp_ipv6.c | =A0 =A02 +-
> =A03 files changed, 18 insertions(+), 9 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
