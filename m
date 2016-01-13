From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] net: add per device sg_max_frags for skb
Date: Wed, 13 Jan 2016 07:44:26 -0800
Message-ID: <CANn89iLabW-Bz7DuECB8PjtbzqYPhxKmYSO3Mj5yPy2-046h5A@mail.gmail.com>
References: <568FA1E5.7060204@stressinduktion.org>
	<569657D8.1020807@oracle.com>
	<CANn89iJtB1qJCbBWUTXFo2LRWobQe6aDFb_KEWUhBNiZCNpdWA@mail.gmail.com>
	<20160113.103825.475570791449704545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Laight <David.Laight@aculab.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Salam Noureddine <noureddine@arista.com>,
	Jarod Wilson <jarod@redhat.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Julian Anastasov <ja@ssi.bg>,
	Ying Xue <ying.xue@windriver.com>,
	Craig Gallek <kraig@google.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Edward Jee <edjee@google.com>,
	Julia Lawall <julia.lawall@lip6.fr>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160113.103825.475570791449704545.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2016 at 7:38 AM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <edumazet@google.com>
> Date: Wed, 13 Jan 2016 06:19:11 -0800
>
>> 2) TCP stack has coalescing support. write(2) or sendmsg(2) should
>> append data into the last skb in write queue, and still use 32 KB
>> frags.
>
> Another way to get pathological SKBs is to do lots of tiny sendpage()
> calls over discontiguous areas of the file.

Yes, this was what I mentioned in the following sentence.
"You get pathological skb when using sendpage() or ..."
