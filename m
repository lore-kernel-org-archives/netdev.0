From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel 4.1 hang, apparently in __inet_lookup_established
Date: Wed, 13 Jan 2016 08:19:50 -0800
Message-ID: <1452701990.1223.67.camel@edumazet-glaptop2.roam.corp.google.com>
References: <564A129F.5060705@fastly.com> <56941035.9040000@fastly.com>
	 <1452546688.1223.1.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160113.110115.616973869173347041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gzhang@fastly.com, kernelorg@bof.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160113.110115.616973869173347041.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-01-13 at 11:01 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 11 Jan 2016 13:11:28 -0800
> 
> > David, can you make sure ed2e923945892a8372ab70d2f61d364b0b6d9054 is
> > pushed to stable trees (4.1 & 4.2)
> 
> It should definitely be there:
> 
> [davem@localhost linux-stable]$ git shortlog v4.1.. -- include/net/inet_timewait_sock.h 
> David S. Miller (1):
>       Merge git://git.kernel.org/.../davem/net
> 
> Eric Dumazet (4):
>       inet: simplify timewait refcounting
>       inet: inet_twsk_deschedule factorization
>       tcp/dccp: fix timewait races in timer handling
>       net: align sk_refcnt on 128 bytes boundary
> 
> Raanan Avargil (1):
>       tcp/dccp: fix old style declarations
> 

Nothing yet on 4.1.15 and 4.2.8


$ git log --oneline v4.1..v4.1.15 -- include/net/inet_timewait_sock.h
$ git log --oneline v4.1..v4.2.8 -- include/net/inet_timewait_sock.h
$ git log --oneline v4.1..v4.4 -- include/net/inet_timewait_sock.h
26440c835f8b Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
8e5eb54d303b net: align sk_refcnt on 128 bytes boundary
8695a144da9e tcp/dccp: fix old style declarations
ed2e92394589 tcp/dccp: fix timewait races in timer handling
dbe7faa4045e inet: inet_twsk_deschedule factorization
fc01538f9fb7 inet: simplify timewait refcounting
$ 
