From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 08 May 2007 10:29:03 +0200
Message-ID: <464034CF.20700@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Michael Jones <mlj28@cam.ac.uk>,
	Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934684AbXEHIa0@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Jones wrote:

>> +#ifndef __ARMEB__
>> +#warning Little endian mode not supported
>> +#endif
> 
> Personally I'm less fussed about WAN / LE support. Anyone with any  
> sense will run ixp4xx boards doing such a specialised network  
> operation as BE. Also, NSLU2-Linux can't test this functionality with  
> our LE setup as we don't have this hardware on-board. You may just  
> want to declare a depends on ARMEB in Kconfig (with or without OR  
> (ARM || BROKEN) ) and have done with it - it's up to you.

Christian Hohnstaedt's work did support LE though.

Not all ixp4xx boards are by definition "doing such a specialised 
network operation".


Krzysztof, why is LE not supported?

Do you need access to ixp4xx that starts in LE mode?


-- 
Tomasz Chmielewski
http://wpkg.org
