From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Thu, 31 Mar 2005 22:13:52 -0800
Message-ID: <20050331221352.13695124.davem@davemloft.net>
References: <42370997.6010302@cosmosbay.com>
	<20050315103253.590c8bfc.davem@davemloft.net>
	<42380EC6.60100@cosmosbay.com>
	<20050316140915.0f6b9528.davem@davemloft.net>
	<4239E00C.4080309@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <4239E00C.4080309@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Mar 2005 20:52:44 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

>     - Move the spinlocks out of tr_hash_table[] to a fixed size table : Saves a lot of memory (particulary on UP)

If spinlock_t is a zero sized structure on UP, how can this save memory
on UP? :-)

Anyways, I think perhaps you should dynamically allocate this lock table.
Otherwise it looks fine.
