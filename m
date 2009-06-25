From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH -tip 0/3] expedited "big hammer" RCU grace periods
Date: Thu, 25 Jun 2009 09:47:02 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0906250944511.3605@localhost.localdomain>
References: <20090624164535.GA13334@linux.vnet.ibm.com> <20090624180303.GE7576@elte.hu> <20090624184423.GK6779@linux.vnet.ibm.com> <20090625095953.GC29980@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, dada1@cosmosbay.com, zbr@ioremap.net,
	jeff.chua.linux@gmail.com, paulus@samba.org, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090625095953.GC29980@elte.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 25 Jun 2009, Ingo Molnar wrote:
> 
> Our general preference is to zap code.
> 
> /me stares at:
> 
>   $ git diff --stat -M v2.6.30..v2.6.31-rc1 | tail -1
>   7743 files changed, 782278 insertions(+), 403162 deletions(-)
> 
> /me corrects himself:

Yes. Our general preference is to zap code, if only because it's so damn 
unusual.

When one out of a hundred patches actually has more removals than 
additions, we make a big deal out of it ("Look - I actually simplified 
things"). For the 99 other patches we never size in polite company.

Oh well. But every time we add lines, we do it with the _best_ intentions.

		Linus
