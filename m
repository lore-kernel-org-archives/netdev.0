From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/14] etherdevice: Add eth_<foo>_addr
 CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS code
Date: Tue, 03 Mar 2015 14:27:58 -0500 (EST)
Message-ID: <20150303.142758.822602589629075339.davem@davemloft.net>
References: <1425407104.17273.27.camel@perches.com>
	<1425408125.5130.191.camel@edumazet-glaptop2.roam.corp.google.com>
	<1425409671.17273.42.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425409671.17273.42.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 03 Mar 2015 11:07:51 -0800

> On Tue, 2015-03-03 at 10:42 -0800, Eric Dumazet wrote:
>> On Tue, 2015-03-03 at 10:25 -0800, Joe Perches wrote:
>> 
>> > At least for arm gcc 4.6.3, it emits different code
>> > for net/l2tp/l2tp_eth.o
>> 
>> Then it looks like arm gcc or arm linux memset() should be improved.
> 
> Perhaps you can take that up with the gcc folk.
> 
> I think it appropriate to improve the actual emitted
> code for the compiler I use.

In the long term, this is poor time spent.  If you fixed GCC
everyone would benefit in the world, not just kernel builders.

Furthermore, none of this crap is in the fast path of anything.

I'm not applying this series, it's basis is not well founded
yet you keep trying to argue otherwise.
