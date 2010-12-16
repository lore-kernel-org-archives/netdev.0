From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] Kernel interfaces for multiqueue aware socket
Date: Thu, 16 Dec 2010 06:00:27 +0100
Message-ID: <1292475627.2603.39.camel@edumazet-laptop>
References: <cover.1292405004.git.fenghua.yu@intel.com>
	 <46a08278c2ba21737528eb4b77391a7e8bc88000.1292405004.git.fenghua.yu@intel.com>
	 <1292446118.2603.11.camel@edumazet-laptop>
	 <AANLkTikc+QTPH2He=fKgWiRGk=6sn9Phaa259YdkQNix@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fenghua Yu <fenghua.yu@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Xinan Tang <xinan.tang@intel.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikc+QTPH2He=fKgWiRGk=6sn9Phaa259YdkQNix@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 09:52 +0800, Junchang Wang a =C3=A9=
crit :
> On Thu, Dec 16, 2010 at 4:48 AM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> >> With this patch, the user-space receiving speed on a Intel SR1690 =
server with
> >> a single L5640 6-core processor and a single ixgbe-based NIC goes =
from 0.73Mpps
> >> to 4.20Mpps, nearly a linear speedup. A Intel SR1625 server two E5=
530 4-core
> >> processors and a single ixgbe-based NIC goes from 0.80Mpps to 4.6M=
pps. We noticed
> >> the performance penalty comes from NUMA memory allocation.
> >>
> >
> > ??? please elaborate on these NUMA memory allocations. This should =
be OK
> > after commit 564824b0c52c34692d (net: allocate skbs on local node)
> >
> Hi Eric,
> Commit 564824b0c52c34692d had been used in the experiments, but the p=
roblem
> remained unsolved.
>=20
> SLUB was used, and both servers were equipped with 8G physical memory=
=2E
> Is there any
> additional information I can provide?
>=20

Yes, sure, you could provide a description of the bench you used, and
data you gathered to make the conclusion that NUMA was a problem.
