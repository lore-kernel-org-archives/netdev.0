From: Andy Hawkins <adhawkins@gmail.com>
Subject: Re: Realtek 8169 based device
Date: Fri, 3 Feb 2012 13:49:31 +0000
Message-ID: <CAOkhdCc4=CpThnnwUxt_6dnUztmUwFX3cSebZdxencejEd1x7A@mail.gmail.com>
References: <CAOkhdCf-emWHJ0rB9GtC3MnX6oj3jgRAbYJU+q65GzMUdXmd-Q@mail.gmail.com>
	<20120203132611.GA21693@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:40522 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756486Ab2BCNtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 08:49:31 -0500
Received: by dadp15 with SMTP id p15so2749211dad.19
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2012 05:49:31 -0800 (PST)
In-Reply-To: <20120203132611.GA21693@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Feb 3, 2012 at 1:26 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Which kernel version is it and does an "XID" line appear for the r8169
> driver in the kernel log ?

Sorry, I realised after hitting send that I hadn't posted the kernel version:

[root@nas ~]# uname -a
Linux nas.gently.org.uk 2.6.29.6-0.30.smp.gcc3.4.x86.i686 #1 SMP Thu
Nov 4 19:54:00 GMT 2010 i686 i686 i386 GNU/Linux

The 8169 driver line is:

[    5.216930] eth1: RTL8169sb/8110sb at 0xf8034000,
4c:00:4e:00:08:fe, XID 10000000 IRQ 16

Ondrej Zary replied to me suggesting I reseat the card as there is
only one bit difference between the Hynic ID (0x106c) and Realtek ID
(0x10ec). I'm at work and the machine is at home, so I can't check
that until later today.

> In the end there may be only two paths left : upgrade the kernel or
> backport the driver.

> It could help if some openfiler developer was available, at the very
> least to retrieve an adequate kernel build tree if backporting is the
> only option.

I have already recompiled the driver to add in the handler for this
ID. If it turns out that this is in fact a correct ID, then at least I
know I can successfully compile and run any code should that become
necessary.

Thanks for the input.

Andy
