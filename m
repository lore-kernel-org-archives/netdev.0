From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Fri, 1 Apr 2005 14:34:42 -0800
Message-ID: <20050401143442.62ed8bb9.davem@davemloft.net>
References: <42370997.6010302@cosmosbay.com>
	<20050315103253.590c8bfc.davem@davemloft.net>
	<42380EC6.60100@cosmosbay.com>
	<20050316140915.0f6b9528.davem@davemloft.net>
	<4239E00C.4080309@cosmosbay.com>
	<20050331221352.13695124.davem@davemloft.net>
	<424D5D34.4030800@cosmosbay.com>
	<20050401122802.7c71afbc.davem@davemloft.net>
	<424DB7A1.8090803@cosmosbay.com>
	<20050401130832.1f972a3b.davem@davemloft.net>
	<424DC08A.3020204@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <424DC08A.3020204@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 01 Apr 2005 23:43:38 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Are you OK if I also use alloc_large_system_hash() to allocate
> rt_hash_table, instead of the current method ? This new method is used
> in net/ipv4/tcp.c for tcp_ehash and tcp_bhash and permits NUMA tuning.

Sure, that's fine.

BTW, please line-wrap your emails. :-/
