From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables -- proto.sockets_allocated
Date: Fri, 27 Jan 2006 16:40:27 -0800
Message-ID: <20060128004027.GE3565@localhost.localdomain>
References: <20060126185649.GB3651@localhost.localdomain> <20060126190357.GE3651@localhost.localdomain> <43D9DFA1.9070802@cosmosbay.com> <20060127195227.GA3565@localhost.localdomain> <20060127121602.18bc3f25.akpm@osdl.org> <43DA9EFF.1020200@cosmosbay.com> <20060127225036.GC3565@localhost.localdomain> <43DAAAE3.2030107@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030209AbWA1AkZ@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <43DAAAE3.2030107@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 28, 2006 at 12:21:07AM +0100, Eric Dumazet wrote:
> Ravikiran G Thirumalai a =E9crit :
> >On Fri, Jan 27, 2006 at 11:30:23PM +0100, Eric Dumazet wrote:
>=20
> Why not use a boot time allocated percpu area (as done today in=20
> setup_per_cpu_areas()), but instead of reserving extra space for modu=
le's=20
> percpu data, being able to serve alloc_percpu() from this reserved ar=
ea (ie=20
> no kmalloced data anymore), and keeping your

At that time ia64 placed a limit on the max size of per-CPU area=20
(PERCPU_ENOUGH_ROOM).  I think that the limit is still there, But hopef=
ully
64K per-CPU should be enough for static + dynamic + modules?

Let me do a allyesconfig on my box and verify.

Thanks,
Kiran
