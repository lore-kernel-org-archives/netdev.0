From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] drivers/net/tile/: on-chip network drivers for the
 tile architecture
Date: Mon, 15 Nov 2010 10:22:10 -0800 (PST)
Message-ID: <20101115.102210.242124777.davem@davemloft.net>
References: <4CD1CE62.9010307@tilera.com>
	<201011140335.oAE3Zuqg032279@farm-0027.internal.tilera.com>
	<20101114075213.GA15495@merkur.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cmetcalf@tilera.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	eric.dumazet@gmail.com
To: sam@ravnborg.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101114075213.GA15495@merkur.ravnborg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sam Ravnborg <sam@ravnborg.org>
Date: Sun, 14 Nov 2010 08:52:13 +0100

>> diff --git a/drivers/net/tile/Makefile b/drivers/net/tile/Makefile
>> new file mode 100644
>> index 0000000..f634f14
>> --- /dev/null
>> +++ b/drivers/net/tile/Makefile
>> @@ -0,0 +1,10 @@
>> +#
>> +# Makefile for the TILE on-chip networking support.
>> +#
>> +
>> +obj-$(CONFIG_TILE_NET) += tile_net.o
>> +ifdef CONFIG_TILEGX
>> +tile_net-objs := tilegx.o mpipe.o iorpc_mpipe.o dma_queue.o
>> +else
>> +tile_net-objs := tilepro.o
>> +endif
> 
> The -objs syntax is deprecated these days.
> Preferred syntax for the above is:

Also please fix the date on your computer, or please change whatever
it is that makes your patch postings use a date in the past.

Thanks.
