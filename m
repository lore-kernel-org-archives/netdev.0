From: Esben Nielsen <nielsen.esben@googlemail.com>
Subject: Re: [PATCH 20/30] Use menuconfig objects - ARCNET
Date: Wed, 11 Apr 2007 11:10:27 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0704111040000.13800@frodo.shire>
References: <Pine.LNX.4.61.0704102046520.32056@yvahk01.tjqt.qr>
 <Pine.LNX.4.61.0704102329540.32056@yvahk01.tjqt.qr>
 <Pine.LNX.4.64.0704111014330.13800@frodo.shire> <Pine.LNX.4.61.0704111034170.32056@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751559AbXDKJKg@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.61.0704111034170.32056@yvahk01.tjqt.qr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 11 Apr 2007, Jan Engelhardt wrote:

>
> On Apr 11 2007 10:30, Esben Nielsen wrote:
>> On Tue, 10 Apr 2007, Jan Engelhardt wrote:
>>>
>>> (Wow, not a single MODULE_AUTHOR line in drivers/net/arcnet/ ...)
>>
>> ArcNet is old. Almost nobody is using it anymore. I used it at my
>> former job, since we used it as control network. A lot of companies
>> still does quitely, but not in combination with Linux.

Let me correct myself: I have only know of one company using the Linux 
ArcNet combination in production. But there must be other companies using 
ArcNet playing with Linux in R&D.

>
> So send some removal patches :)

No. Somebody (like me) in those companise use them sporadically for their 
PCI/PCMCIA cards. The vendor have some basic Windoze drives. Missing Linux 
drivers should not be yet another obstacle for using Linux.

They might also one day want to run Linux on their embedded platform - 
especially with preempt-realtime. When I at my former job got Linux to boot
at our embedded platform their I could almost immediately use the onboard
ArcNet controller. For the propriatary OS otherwise used on those platforms it
took many man weeks to write a driver.

Keeping support for old devices in the kernel tree is a good for Linux. It 
should take too long updating it for API changes and although they might 
not work, but if the occational user is capable enough, he can soon fix 
them. If they are are removed the occational user will choose another OS.

Esben
