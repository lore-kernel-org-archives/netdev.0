From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Wed, 16 Mar 2005 14:09:15 -0800
Message-ID: <20050316140915.0f6b9528.davem@davemloft.net>
References: <42370997.6010302@cosmosbay.com>
	<20050315103253.590c8bfc.davem@davemloft.net>
	<42380EC6.60100@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <42380EC6.60100@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Mar 2005 11:47:34 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> The rt_check_expire() has a serious problem on machines with large
> route caches, and a standard HZ value of 1000.
> 
> With default values, ie ip_rt_gc_interval = 60*HZ = 60000 ;
> 
> the loop count :
> 
>      for (t = ip_rt_gc_interval << rt_hash_log; t >= 0;
> 
> 
> overflows (t is a 31 bit value) as soon rt_hash_log is >= 16  (65536
> slots in route cache hash table)
 ...
> I am experimenting some changes that I will share when ready.

Good catch, let us know when you have a patch for review.
