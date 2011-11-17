From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH FIX net-next v1] net-forcedeth: fix possible stats
 inaccuracies on 32b hosts
Date: Thu, 17 Nov 2011 21:08:15 +0100
Message-ID: <1321560495.2444.1.camel@edumazet-laptop>
References: <cover.1321558587.git.david.decotigny@google.com>
	 <34add86253ddd91d5d4d4c7fee9c90f63a8d8edf.1321558587.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Rick Jones <rick.jones2@hp.com>
To: David Decotigny <david.decotigny@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <34add86253ddd91d5d4d4c7fee9c90f63a8d8edf.1321558587.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 17 novembre 2011 =C3=A0 11:38 -0800, David Decotigny a =C3=A9c=
rit :
> The software stats are updated from BH, this change ensures that 32b
> UP hosts use appropriate protection.
>=20
> Tested:
>   - HW/SW stats consistent with pktgen (in particular tx=3Drx)
>   - HW/SW stats consistent when tx/rx offloads disabled
>   - no problem with+without lockdep (SMP 16-way)
>=20
>=20
>=20
> Signed-off-by: David Decotigny <david.decotigny@google.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
