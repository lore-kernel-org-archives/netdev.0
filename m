From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: [PATCH] dummy: improve performance
Date: Thu, 26 May 2005 09:03:29 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0505260900100.7768@webhosting.rdsbv.ro>
References: <Pine.LNX.4.62.0505201306110.29305@webhosting.rdsbv.ro>
 <20050525.151149.08323692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050525.151149.08323692.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 May 2005, David S. Miller wrote:

> From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
> Date: Fri, 20 May 2005 13:11:24 +0300 (EEST)
>
>> I tested the speed and seems very low (both old version and the new one).
>> Something like 37Mbits/s. It is normal?
>> I can easily get 80Mbit/s on the same machine on ethernet.
>
> How are you receiving packets on the dummy device for
> performance testing?  This device is a transmit blackhole
> and receives no packets :-)

I only test the output part. I measure how time it takes to send an amount 
of data (icmp or udp).

> I really don't see a real need for your patch, dummy device
> performance cannot be claimed to be important at all.

Of course it's not very important.
But if someone is using it, why not at full speed?

Thanks.

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
