From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/4] net,rcu: don't assume the size of struct rcu_head
Date: Tue, 01 Mar 2011 09:20:55 +0100
Message-ID: <1298967655.2676.66.camel@edumazet-laptop>
References: <4D6CA860.3020409@cn.fujitsu.com>
	 <20110301.001638.104075130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: laijs@cn.fujitsu.com, mingo@elte.hu, paulmck@linux.vnet.ibm.com,
 cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com,
 linux-mm@kvack.org,  linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20110301.001638.104075130.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le mardi 01 mars 2011 =C3=A0 00:16 -0800, David Miller a =C3=A9crit :
> From: Lai Jiangshan <laijs@cn.fujitsu.com>
> Date: Tue, 01 Mar 2011 16:03:44 +0800
>=20
> >=20
> > struct dst_entry assumes the size of struct rcu_head as 2 * sizeof(lo=
ng)
> > and manually adds pads for aligning for "__refcnt".
> >=20
> > When the size of struct rcu_head is changed, these manual padding
> > is wrong. Use __attribute__((aligned (64))) instead.
> >=20
> > Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
>=20
> We don't want to use the align if it's going to waste lots of space.
>=20
> Instead we want to rearrange the structure so that the alignment comes
> more cheaply.

Oh well, I should have read your answer before sending mine :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
