From: Ben Greear <greearb@candelatech.com>
Subject: Re: 2.4.21: bug report for tg3:  tx lockup when changing MTU
Date: Sat, 02 Aug 2003 20:48:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2C8623.2080106@candelatech.com>
References: <3F2AEFBF.3040604@candelatech.com> <Pine.LNX.4.53.0308021122290.27834@eco.foo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Sascha Schumann <sascha@schumann.cx>
In-Reply-To: <Pine.LNX.4.53.0308021122290.27834@eco.foo>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sascha Schumann wrote:
>>Kernel is 2.4.21 + custom patches (which should not affect tg3).
>>
>>lspci says the NIC is: Altima AC9100 (rev 15)
> 
> 
>     [1] says that the AC9100 based Netgear GA302T cards don't
>     support jumbo frames.  I'm seeing regular lockups once
>     packets larger than 1500bytes flow through the NIC.
> 
>     It would be cool though if this turned out to be a driver
>     limitation and not a (crippled) chipset issue.

It definately handles 4000 byte frames just fine, you just need to
ifdown and ifup it after changing the MTU much of the time...or maybe
only when running it under heavy load when you make the MTU change...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
