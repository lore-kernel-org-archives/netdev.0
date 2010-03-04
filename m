From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH -next] bridge: depends on INET
Date: Wed, 03 Mar 2010 20:00:22 -0800
Message-ID: <4B8F3056.1010109@oracle.com>
References: <20100302180915.1388d3f3.sfr@canb.auug.org.au> <4B8D4607.8070603@xenotime.net> <20100303.012359.66790294.davem@davemloft.net> <20100304031847.GA22683@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100304031847.GA22683@elte.hu>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/03/10 19:18, Ingo Molnar wrote:
> 
> * David Miller <davem@davemloft.net> wrote:
> 
>> From: Randy Dunlap <rdunlap@xenotime.net>
>> Date: Tue, 02 Mar 2010 09:08:23 -0800
>>
>>> From: Randy Dunlap <randy.dunlap@oracle.com>
>>>
>>> br_multicast calls ip_send_check(), so it should depend on INET.
>>>
>>> built-in:
>>> br_multicast.c:(.text+0x88cf4): undefined reference to `ip_send_check'
>>>
>>> or modular:
>>> ERROR: "ip_send_check" [net/bridge/bridge.ko] undefined!
>>>
>>> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
>>
>> Applied, but I almost lost this patch.
>>
>> You need to CC: netdev on all networking patches so that it
>> gets properly tracked in patchwork and therefore does not get
>> lost.
> 
> I suspect Randy went by the MAINTAINERS entry - you might want to add netdev 
> as a second 'L:' line:
> 
>  ETHERNET BRIDGE
>  M:      Stephen Hemminger <shemminger@linux-foundation.org>
>  L:      bridge@lists.linux-foundation.org
>  W:      http://www.linux-foundation.org/en/Net:Bridge
>  S:      Maintained
>  F:      include/linux/netfilter_bridge/
>  F:      net/bridge/
> 
> To make it really clear that netdev must be Cc:-ed for those patches.

Ack that.  I also expected Stephen to merge it...

-- 
~Randy
