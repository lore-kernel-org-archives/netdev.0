From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Thu, 30 Dec 2004 00:52:03 +0100
Message-ID: <20041229235203.GA5465@electric-eye.fr.zoreil.com>
References: <41A09541.5040405@phekda.gotadsl.co.uk> <41A0F0D5.9050702@phekda.gotadsl.co.uk> <20041121205814.GA22460@electric-eye.fr.zoreil.com> <41A24F35.5080106@phekda.gotadsl.co.uk> <20041122213008.GA9618@electric-eye.fr.zoreil.com> <41D2844E.5070204@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
Content-Disposition: inline
In-Reply-To: <41D2844E.5070204@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Dawe <rich@phekda.gotadsl.co.uk> :
[...]
> IRQ routing seems to be disabled in 2.6.10. I got a warning about an 
> unhandled interrupt for the VIA 8255 (I think that's the right number) 
> on shutdown. I'm wondering if there is some bad interaction between the 
> VIA chipset and the 8110 chipset.

Possible. I hope the networking does not perform better when you are
listening to music.

> Another datapoint: On a Netgear switch at work, I had to put the chipset 
> into 100Mbps half-duplex and set the MTU to 576 bytes, to get any decent 
> performance out of at it.
> 
> Anyway, I need to do more investigation.

Could you send an updated dmesg, lspci -vvx, /proc/interrupts please ?

Did you remove the other OS from the laptop ? I'd be curious to know
if it can teach us something.

--
Ueimor
