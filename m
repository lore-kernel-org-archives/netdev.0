From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Mon, 22 Nov 2004 20:42:29 +0000
Message-ID: <41A24F35.5080106@phekda.gotadsl.co.uk>
References: <41A09541.5040405@phekda.gotadsl.co.uk> <41A0F0D5.9050702@phekda.gotadsl.co.uk> <20041121205814.GA22460@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Me <rich@phekda.gotadsl.co.uk>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041121205814.GA22460@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Francois Romieu wrote:
> Richard Dawe <rich@phekda.gotadsl.co.uk> :
> [...]
> 
>>I've got it working with 10Mbps full-duplex now. Here are the lines from 
>>modprobe.conf:
>>
>>  alias eth0 r8169
>>  options eth0 use_dac=0 media=0x2
> 
> 
> It makes sense. use_dac=1 is reported to badly fail on amd64 most of
> time.

I didn't see any crashes or hangs with use_dac enabled (or rather, not 
disabled).

I haven't tried use_dac=1 with media=0x2, though. Maybe that would give 
enough traffic to crash or hang my box.

> Can you try 2.6.10-rc2 +
> http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.10-rc2-netdev1.patch.bz2 +
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.10-rc2-mm1/r8169-250.patch +
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.10-rc2-mm1/r8169-255.patch

No, that suffers from the same problems.

How do these patches differ from those in 2.6.10-rc2-mm2?

Let me know if there are any other patches you want me to try.

> Is it an option for you to disable ACPI, remove the media specification
> and simply issue an 'ethtool eth0' a few tens of seconds after insertion
> of the module ?

Sadly my box won't boot, if I disable ACPI.

> It takes ages to negotiate here (Netgear switch + 8169 PCI adapter).
[snip]

It seems to negotiate pretty quickly with my DSL router. Less than a 
second, I'd say. I can time it a bit more exactly, if it would help.

 From your ethtool patch, it looks like I have a 8110. I did search 
their specs for version registers, etc., but I could not see them. Where 
did you get your datasheet from for the 8110?

Thanks, bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
