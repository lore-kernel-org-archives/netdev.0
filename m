From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Mon, 22 Nov 2004 22:30:09 +0100
Message-ID: <20041122213008.GA9618@electric-eye.fr.zoreil.com>
References: <41A09541.5040405@phekda.gotadsl.co.uk> <41A0F0D5.9050702@phekda.gotadsl.co.uk> <20041121205814.GA22460@electric-eye.fr.zoreil.com> <41A24F35.5080106@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
Content-Disposition: inline
In-Reply-To: <41A24F35.5080106@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Dawe <rich@phekda.gotadsl.co.uk> :
[...]
> I didn't see any crashes or hangs with use_dac enabled (or rather, not 
> disabled).

It defaults to 0. Set it to 1 if you dare (once the current issues are
fixed, ok ? :o) ).

> I haven't tried use_dac=1 with media=0x2, though. Maybe that would give 
> enough traffic to crash or hang my box.

media=... ought to be obsolete.

I'll check if there is something relevant for ethtool on RH bugzilla.
It should not segfault.

[...]
> No, that suffers from the same problems.

Thanks anyway.

> How do these patches differ from those in 2.6.10-rc2-mm2?

The Tx timeout recovery sequence suggested by Jon Mason works for me.

[...]
> Sadly my box won't boot, if I disable ACPI.

Can you give a look at:
http://forums.gentoo.org/viewtopic.php?t=122145%22%22

Ac*r, laptop, acpi and x64 are making me paranoid.

> >It takes ages to negotiate here (Netgear switch + 8169 PCI adapter).
> [snip]
> 
> It seems to negotiate pretty quickly with my DSL router. Less than a 
> second, I'd say. I can time it a bit more exactly, if it would help.

It is not necessary.

> From your ethtool patch, it looks like I have a 8110. I did search 
> their specs for version registers, etc., but I could not see them. Where 
> did you get your datasheet from for the 8110?

I got my rtl8169spec-121.pdf from Realtek's website when their search
engine was still working. Now you'd better use Google.

There are some typos in the datasheet as some parts seems to have been
copy/pasted from the 8139C+ manual. Some registers are missing (0xe2,
0x48 ?).

--
Ueimor
