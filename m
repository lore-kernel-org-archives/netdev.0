From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] ariadne: convert to net_device_ops
Date: Sat, 11 Apr 2009 02:56:26 -0700 (PDT)
Message-ID: <20090411.025626.125053437.davem@davemloft.net>
References: <20090410032407.GA9004@orion>
	<49DF7042.7090502@computer.org>
	<20090410175924.GA20243@orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jan.ceuleers@computer.org, netdev@vger.kernel.org,
	linux-m68k@vger.kernel.org, geert@linux-m68k.org
To: a.beregalov@gmail.com
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20090410175924.GA20243@orion>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Fri, 10 Apr 2009 21:59:24 +0400

> On Fri, Apr 10, 2009 at 06:13:54PM +0200, Jan Ceuleers wrote:
>> Alexander Beregalov wrote:
>> > 
>> > Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
>> ...
>> > @@ -197,13 +209,8 @@ static int __devinit ariadne_init_one(struct zorro_dev *z,
>> >      dev->mem_start = ZTWO_VADDR(mem_start);
>> >      dev->mem_end = dev->mem_start+ARIADNE_RAM_SIZE;
>> >  
>> > -    dev->open = &ariadne_open;
>> > -    dev->stop = &ariadne_close;
>> > -    dev->hard_start_xmit = &ariadne_start_xmit;
>> > -    dev->tx_timeout = &ariadne_tx_timeout;
>> > +    dev->netdev_ops = &ariadne_netdev_ops;;
>> 
>> We don't really need two semicolons there but I suppose that they won't 
>> hurt.
> Thanks!
> 
> David, please apply this patch

Just FYI I made sure to integrate this fixed up version.
