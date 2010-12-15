From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] Kernel interfaces for multiqueue aware socket
Date: Wed, 15 Dec 2010 21:56:07 +0100
Message-ID: <1292446567.2603.15.camel@edumazet-laptop>
References: <cover.1292405004.git.fenghua.yu@intel.com>
	 <46a08278c2ba21737528eb4b77391a7e8bc88000.1292405004.git.fenghua.yu@intel.com>
	 <1292446118.2603.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Xinan Tang <xinan.tang@intel.com>,
	Junchang Wang <junchangwang@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Fenghua Yu <fenghua.yu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292446118.2603.11.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 21:48 +0100, Eric Dumazet a =C3=
=A9crit :
> Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 12:02 -0800, Fenghua Yu a =C3=
=A9crit :
> > From: Fenghua Yu <fenghua.yu@intel.com>
> >=20
> > Multiqueue and multicore provide packet parallel processing methodo=
logy.
> > Current kernel and network drivers place one queue on one core. But=
 the higher
> > level socket doesn't know multiqueue. Current socket only can recei=
ve or send
> > packets through one network interfaces. In some cases e.g. multi bp=
f filter
> > tcpdump and snort, a lot of contentions come from socket operations=
 like ring
> > buffer. Even if the application itself has been fully parallelized =
and run on
> > multi-core systems and NIC handlex tx/rx in multiqueue in parallel,=
 network layer
> > and NIC device driver assemble packets to a single, serialized queu=
e. Thus the
> > application cannot actually run in parallel in high speed.

I forgot to say that your patches are not against net-next-2.6, and not
apply anyway.

Always use David trees for networking patches...
