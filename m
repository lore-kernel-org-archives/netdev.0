From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: hackbench regression due to commit 9dfc6e68bfe6e
Date: Thu, 08 Apr 2010 09:25:51 +0200
Message-ID: <1270711551.2215.5.camel@edumazet-laptop>
References: <1270702774.8141.49.camel@edumazet-laptop>
	 <1270705153.8141.58.camel@edumazet-laptop>
	 <1270710019.2215.4.camel@edumazet-laptop>
	 <20100408.000557.180546976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yanmin_zhang@linux.intel.com, cl@linux-foundation.org,
	penberg@cs.helsinki.fi, netdev@vger.kernel.org, tj@kernel.org,
	alex.shi@intel.com, linux-kernel@vger.kernel.org,
	ling.ma@intel.com, tim.c.chen@intel.com, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100408.000557.180546976.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 08 avril 2010 =C3=A0 00:05 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 08 Apr 2010 09:00:19 +0200
>=20
> > If run individually, the tests results are more what we would expec=
t
> > (slow), but if machine runs the two set of process concurrently, ea=
ch
> > group runs much faster...
>=20
> BTW, I just discovered (thanks to the function graph tracer, woo hoo!=
)
> that loopback TCP packets get fully checksum validated on receive.
>=20
> I'm trying to figure out why skb->ip_summed ends up being
> CHECKSUM_NONE in tcp_v4_rcv() even though it gets set to
> CHECKSUM_PARTIAL in tcp_sendmsg().
>=20
> I wonder how much this accounts for some of the hackbench
> oddities... and other regressions in loopback tests we've seen.
> :-)
>=20
> Just FYI...

Thanks !

But hackbench is a af_unix benchmark, so loopback stuff is not used tha=
t
much :)
