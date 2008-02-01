From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: R8101 driver link issue
Date: Sat, 2 Feb 2008 00:01:41 +0100
Message-ID: <20080201230141.GA6518@electric-eye.fr.zoreil.com>
References: <47A37B04.3060909@switact.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Switact - Thomas Roes <info@switact.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:33868 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753715AbYBAXTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 18:19:07 -0500
Content-Disposition: inline
In-Reply-To: <47A37B04.3060909@switact.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switact - Thomas Roes <info@switact.nl> :
[...]
> Recently I got problems with a new motherbord using the Realtek RTL8101E 
> PCI Express Fast Ethernet controller.
>
> This card is recognised by the r8169 driver but.... it always gives me 
> "link down".

Can you send the output of 'lspci -vvxxx' and the dmesg of a recent kernel ?

It should include a line like this one:
[...]
eth0: RTL8168b/8111b at 0xf8920000, 00:13:8f:ea:b1:5d, XID 38000000 IRQ 221
                                                       ^^^
[...]
> So i searched for drivers to compile and came across the 
> r8101-1.006.tar.bz2 driver.

Ok.

[...]
> -2 but unfortunately, also this new driver, although it get's loaded, it 
> still reports (ethtool eth0)....
> current message level : 0x0..033 (51)
> Link detected : no

Can you send the output of mii-diag and try so force a reset with this
driver ?

-- 
Ueimor
