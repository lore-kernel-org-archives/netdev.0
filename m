From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 Driver History
Date: Tue, 16 Oct 2007 22:29:17 +0200
Message-ID: <20071016202917.GA8686@electric-eye.fr.zoreil.com>
References: <47139917.6050001@kbocek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: Kirk Bocek <t004@kbocek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58649 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965153AbXJPUdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 16:33:04 -0400
Content-Disposition: inline
In-Reply-To: <47139917.6050001@kbocek.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kirk Bocek <t004@kbocek.com> :
> I'm maintaining a CentOS wiki page for the RTL8110 NIC:
> 
> http://wiki.centos.org/HardwareList/RealTekr1000
> 
> I don't think I have the version history quite right between the 2.2LK-NAPI
> version of the driver that's included in the kernel and the 6.003.00-NAPI
> version that Realtek has posted on their site. Can anyone point me to correct
> information that I can post on the wiki.

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=history;f=drivers/net/r8169.c;h=419c00cbe6e962bac5e1ea095848628415566e51;hb=HEAD

2.2LK-NAPI has stopped being a relevant identifier loooong ago.

The comments at the start of the 6.00x.00 files suggest a different history,
but 6.00x.00 is quite close to some in-kernel 2.6.x version.

> On a related issue, I also have a page for the RTL8111 NIC that requires
> Realtek's r8168 driver. What are the plans for adding that driver to the
> kernel ?

The current in-kernel r8169 driver has some support for the 8168 devices,
especially the "B" ones. People should try it and report when its behavior
and the 6.00x.00 one differ. Otherwise my plan is very simple: compare
6.00n.00 against 6.00(n-1), figure the candidate changes, compare against
the in-kernel driver, test the changes, add them, try again, repeat until
judgment day.

-- 
Ueimor
