From: "David TILLOY" <dtilloy@neocom.fr>
Subject: RE: Fw: [Bugme-new] [Bug 2782] New: ksoftirqd load system, kernelha
	ng after a few minuts
Date: Fri, 28 May 2004 14:00:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <IAENKNLIAFMLPMFJNMOBOELPCOAA.dtilloy@neocom.fr>
References: <40B715F3.9010200@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <P@draigBrady.com>, "Andrew Morton" <akpm@osdl.org>
In-Reply-To: <40B715F3.9010200@draigBrady.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[...]
> > http://bugme.osdl.org/show_bug.cgi?id=2782
> >
> >            Summary: ksoftirqd load system, kernel hang after a
> few minuts
> >     Kernel Version: 2.4.20-2.4.22
> >             Status: NEW
> >           Severity: blocking
> >              Owner: other_other@kernel-bugs.osdl.org
> >          Submitter: dav@neocom.fr
>
> I've just seen something similar with official 2.4.20+e1000 v5.2.30.1
> on a Dual Intel Xeon CPU 2.6G+hyperthreading. Note I use IRQ affinity
> so both ksoftirqd_CPU[02] are at 100%.

I've tried to use IRQ affinnity too, but without success, with or without.
I've tried to switch hyperthreading off into bios, without more success.
I've tried to deactive ACPI into bios too, problem is the same.
>
> The following is repeatable in about a minute which is good.
> I send in around 700,000 packets per second on each of 2 interfaces,
> and let the packets continually overflow the (4096 entry) buffers.
> After about a minute I can't receive any traffic, and a couple
> of occasions the machine just rebooted, so something is getting
> corrupted. I was suspecting the e1000 driver buffer management until
> I seen this?

I've repeated this trouble with some NIC card. I've reproduced this with tg3
driver (Broadcom gigabit NIC), Dual Intel PRO/100S, tg2 driver and bcm5700
driver.

regards,
David.
--
