From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] time: jiffies_delta_to_clock_t() helper to
 the rescue
Date: Thu, 09 Aug 2012 16:17:22 -0700 (PDT)
Message-ID: <20120809.161722.978110433246227213.davem@davemloft.net>
References: <1344496433.28967.443.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tglx@linutronix.de, maze@google.com, paul.gortmaker@windriver.com,
	akpm@linux-foundation.org, pyu@redhat.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344496433.28967.443.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Aug 2012 09:13:53 +0200

> From: Eric Dumazet <edumazet@google.com>
>=20
> Various /proc/net files sometimes report crazy timer values, expresse=
d
> in clock_t units.
>=20
> This happens when an expired timer delta (expires - jiffies) is passe=
d
> to jiffies_to_clock_t().
>=20
> This function has an overflow in :
>=20
> return div_u64((u64)x * TICK_NSEC, NSEC_PER_SEC / USER_HZ);
>=20
> commit cbbc719fccdb8cb (time: Change jiffies_to_clock_t() argument ty=
pe
> to unsigned long) only got around the problem.
>=20
> As we cant output negative values in /proc/net/tcp without breaking
> various tools, I suggest adding a jiffies_delta_to_clock_t() wrapper
> that caps the negative delta to a 0 value.
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Maciej =AFenczykowski <maze@google.com>

Applied, thanks Eric.
