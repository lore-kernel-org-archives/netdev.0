From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [PATCH 20/30] Use menuconfig objects - ARCNET
Date: Wed, 11 Apr 2007 10:38:38 +0200 (MEST)
Message-ID: <Pine.LNX.4.61.0704111034170.32056@yvahk01.tjqt.qr>
References: <Pine.LNX.4.61.0704102046520.32056@yvahk01.tjqt.qr>
 <Pine.LNX.4.61.0704102329540.32056@yvahk01.tjqt.qr>
 <Pine.LNX.4.64.0704111014330.13800@frodo.shire>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Esben Nielsen <nielsen.esben@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751131AbXDKIj2@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0704111014330.13800@frodo.shire>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Apr 11 2007 10:30, Esben Nielsen wrote:
> On Tue, 10 Apr 2007, Jan Engelhardt wrote:
>> 
>> (Wow, not a single MODULE_AUTHOR line in drivers/net/arcnet/ ...)
>
> ArcNet is old. Almost nobody is using it anymore. I used it at my
> former job, since we used it as control network. A lot of companies
> still does quitely, but not in combination with Linux.

So send some removal patches :)

>> 
>> -menu "ARCnet devices"
>> +menuconfig ARCNET
>> depends on NETDEVICES && (ISA || PCI)
>
> Why does it depend on ISA || PCI ?

No idea. I just left it as is.

> People tend to forget the PCMCIA driver.

Somewhat somewhat. 32-bit PCMCIA (CONFIG_CARDBUS) depends on PCI,
so with (ISA || PCI) you have probably everything minus
{sbus, mca, 16 bit pcmcia, other exotic parts}.

> And in principle you could enable the ArcNet framework
> without using any of the drivers in the kernel tree.


Jan
-- 
