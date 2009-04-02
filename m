From: Sajith P V <sajithpv@gmail.com>
Subject: Re: [PATCH] i.MX31: Fixing cs89x0 network building to i.MX31ADS
Date: Thu, 2 Apr 2009 17:38:09 +0530
Message-ID: <155d92380904020508vffc0480j3973973fd4e97fce@mail.gmail.com>
References: <37367b3a0903241018h7ff3302fi83cf1fcb21a3114d@mail.gmail.com>
	 <37367b3a0903300714g40a108d3j59a3b56ee9cda2bf@mail.gmail.com>
	 <20090330143155.GA20101@pengutronix.de>
	 <37367b3a0903301315u51787ebcl119ed295e373a1e4@mail.gmail.com>
	 <20090331075951.GF22913@pengutronix.de>
	 <37367b3a0903310636x3c8d8eban4310018c3d1b40b@mail.gmail.com>
	 <155d92380904010454l34c57687j67e6805dafcb92ef@mail.gmail.com>
	 <37367b3a0904010704o34aa5532p4bc8b3c9a8c16f7f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>
To: Alan Carvalho de Assis <acassis@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:61774 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbZDBMIM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 08:08:12 -0400
Received: by wf-out-1314.google.com with SMTP id 29so604549wff.4
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2009 05:08:09 -0700 (PDT)
In-Reply-To: <37367b3a0904010704o34aa5532p4bc8b3c9a8c16f7f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alan

On Wed, Apr 1, 2009 at 7:34 PM, Alan Carvalho de Assis
<acassis@gmail.com> wrote:
> It is strange, here I got a similar message:
> cs89x0:cs89x0_probe(0x0)
> cs89x0.c: v2.4.3-pre1 Russell Nelson <nelson@crynwr.com>, Andrew Mort=
on
> eth0: cs8900 rev K found at 0xf4020300 [Cirrus EEPROM]
> cs89x0 media RJ-45, IRQ 168, programmed I/O, MAC 00:04:9f:00:41:87
> cs89x0_probe1() successful
> cs89x0:cs89x0_probe(0x0)
> cs89x0: request_region(0xf4020300, 0x10) failed
> cs89x0: no cs8900 or cs8920 detected. =A0Be sure to disable PnP with =
SETUP
>
> But network works fine:
> $ ping 10.29.240.182
> PING 10.29.240.182 (10.29.240.182): 56 data bytes
> 64 bytes from 10.29.240.182: seq=3D0 ttl=3D63 time=3D0.6 ms
> 64 bytes from 10.29.240.182: seq=3D1 ttl=3D63 time=3D0.6 ms
>

What is cs8900_irq_map set to with this patch or am I missing some thin=
g?

Regards,
Sajith
