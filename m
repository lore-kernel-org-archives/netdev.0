From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [PATCH] fs: pipe/sockets/anon dentries should not have a parent
Date: Fri, 21 Nov 2008 16:21:48 +0100
Message-ID: <20081121152148.GA20388@elte.hu>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	rjw-KKrjLPT3xs0@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, efault-Mmb7MZpHnFY@public.gmane.org,
	a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4926D022.5060008-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


* Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org> wrote:

> Before patch, time to run 8 millions of close(socket()) calls on 8 
> CPUS was :
>
> real    0m27.496s
> user    0m0.657s
> sys     3m39.092s
>
> After patch :
>
> real    0m23.997s
> user    0m0.682s
> sys     3m11.193s

cool :-)

What would it take to get it down to:

>> Cost if run one one cpu :
>>
>> real    0m1.561s
>> user    0m0.092s
>> sys     0m1.469s

i guess asking for a wall-clock cost of 1.561/8 would be too much? :)

	Ingo
