From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Fri, 1 Apr 2005 15:54:42 -0800
Message-ID: <20050401155442.3bbd6a73.davem@davemloft.net>
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
	<20050401143442.62ed8bb9.davem@davemloft.net>
	<424DD78D.7070001@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <424DD78D.7070001@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 02 Apr 2005 01:21:49 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> OK this patch includes everything...
> 
>   - Locking abstraction
>   - rt_check_expire() fixes
>   - New gc_interval_ms sysctl to be able to have timer gc_interval < 1 second
>   - New gc_debug sysctl to let sysadmin tune gc
>   - Less memory used by hash table (spinlocks moved to a smaller table)
>   - sizing of spinlocks table depends on NR_CPUS
>   - hash table allocated using alloc_large_system_hash() function
>   - header fix for /proc/net/stat/rt_cache

Looks fine to me.

I'd like to see some feedback from folks like Robert Olsson
and co. before applying this, so let's allow the patch to
simmer over the weekend, ok? :-)
