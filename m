From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Wed, 29 Dec 2004 10:17:50 +0000
Message-ID: <41D2844E.5070204@phekda.gotadsl.co.uk>
References: <41A09541.5040405@phekda.gotadsl.co.uk> <41A0F0D5.9050702@phekda.gotadsl.co.uk> <20041121205814.GA22460@electric-eye.fr.zoreil.com> <41A24F35.5080106@phekda.gotadsl.co.uk> <20041122213008.GA9618@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Me <rich@phekda.gotadsl.co.uk>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041122213008.GA9618@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Francois Romieu wrote:
> Richard Dawe <rich@phekda.gotadsl.co.uk> :
[snip]
>>Sadly my box won't boot, if I disable ACPI.
> 
> 
> Can you give a look at:
> http://forums.gentoo.org/viewtopic.php?t=122145%22%22
> 
> Ac*r, laptop, acpi and x64 are making me paranoid.
[snip]

I patched up my ACPI DSDT to compile without errors, rebuilt 2.6.10 
final with the patched ACPI DSDT built-in. Network performance is still 
appalling (massive packet loss).

IRQ routing seems to be disabled in 2.6.10. I got a warning about an 
unhandled interrupt for the VIA 8255 (I think that's the right number) 
on shutdown. I'm wondering if there is some bad interaction between the 
VIA chipset and the 8110 chipset.

Another datapoint: On a Netgear switch at work, I had to put the chipset 
into 100Mbps half-duplex and set the MTU to 576 bytes, to get any decent 
performance out of at it.

Anyway, I need to do more investigation.

Thanks, bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
