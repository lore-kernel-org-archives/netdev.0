From: Markus Feldmann <feldmann_markus@gmx.de>
Subject: Re: [PATCH 0/2] PCI runtime power management for r8169 and e1000e
Date: Thu, 22 Apr 2010 22:19:10 +0200
Message-ID: <hqqavu$a65$1@dough.gmane.org>
References: <201003150131.59619.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:38388 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758296Ab0DVUTc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 16:19:32 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1O52ru-0002nj-9g
	for netdev@vger.kernel.org; Thu, 22 Apr 2010 22:19:26 +0200
Received: from dslb-092-076-232-046.pools.arcor-ip.net ([92.76.232.46])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 22:19:26 +0200
Received: from feldmann_markus by dslb-092-076-232-046.pools.arcor-ip.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 22:19:26 +0200
In-Reply-To: <201003150131.59619.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafael J. Wysocki schrieb:
> Hi,
> 
> The following two patches add basic PCI runtime power management to the r8169
> and e1000e drivers.
> 
> It works so that the adapter is put into PCI D3 if there's no network cable
> attached to it and back into PCI D0 once the cable has been detected.
> 
> The feature is disabled by default and it can be enabled by writing "auto" to
> the device's /sys/devices/.../power/control file.  Writing "on" to this file
> disables the feature again.
> 
> The patches have been tested on MSI Wind U100 (r8169) and Toshiba Portege
> R500 (e1000e).
> 
> Thanks,
> Rafael
> 

Hi Rafael,

Which kernel do i need for this feature? I have a mini-itx board 
combined with a daughterboard with additionally 3xRJ45, so that i have 4 
network devices:
...
01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 03)
04:04.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL-8110SC/8169SC Gigabit Ethernet (rev 10)
04:06.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL-8110SC/8169SC Gigabit Ethernet (rev 10)
04:07.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL-8110SC/8169SC Gigabit Ethernet (rev 10)

Not all of them are used at the same time. So how can i put the unused 
in a low power state?

regards Markus

