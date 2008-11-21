From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Subject: Re: [PATCH] fs: pipe/sockets/anon dentries should not have a parent
Date: Fri, 21 Nov 2008 16:28:29 +0100
Message-ID: <4926D39D.9050603@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	rjw-KKrjLPT3xs0@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, efault-Mmb7MZpHnFY@public.gmane.org,
	a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081121152148.GA20388-X9Un+BFzKDI@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ingo Molnar a =E9crit :
> * Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org> wrote:
>=20
>> Before patch, time to run 8 millions of close(socket()) calls on 8=20
>> CPUS was :
>>
>> real    0m27.496s
>> user    0m0.657s
>> sys     3m39.092s
>>
>> After patch :
>>
>> real    0m23.997s
>> user    0m0.682s
>> sys     3m11.193s
>=20
> cool :-)
>=20
> What would it take to get it down to:
>=20
>>> Cost if run one one cpu :
>>>
>>> real    0m1.561s
>>> user    0m0.092s
>>> sys     0m1.469s
>=20
> i guess asking for a wall-clock cost of 1.561/8 would be too much? :)
>=20

It might be possible, depending on the level of hackery I am allowed to=
 inject
in fs/dcache.c and fs/inode.c :)

wall cost of 1.56 (each cpu runs one loop of one million iterations)
