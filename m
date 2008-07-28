From: "martin capitanio" <martin@capitanio.org>
Subject: Re: [patch inside] kernel crash, RTL8101E [10ec:8136]
Date: Mon, 28 Jul 2008 22:58:14 +0200 (MEST)
Message-ID: <200807282058.m6SKwE8o026003@post.webmailer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Mario Limonciello" <Mario_Limonciello@Dell.com>,
	"Edward Hsu" <edward_hsu@realtek.com.tw>, netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cg-p00-ob.rzone.de ([81.169.146.193]:58023 "EHLO
	cg-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755880AbYG1U6X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 16:58:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [...]
> > The pci entry just confuse people, the correct message were something
> like
> > Realtek Semiconductor Co., Ltd. RTL81xxx Ethernet controller
> 
> 10ec:8136 covers the 8101 and the 8102, as expected.
Then RTL8101(E)/8102(E) ?
I get here RTL8101E but the real hardware is RTL8102E
The website claims RTL8139  and what ever. If that's not the case ...
> 
> > Everything depending on this information may break, right?
> > drivers/net/r8169.c:166:{
> PCI_DEVICE(PCI_VENDOR_ID_REALTEK,0x8136),0,0,RTL_CFG_2 },
> 
> I do not get it. Where do you see a breakage ?
Sorry misunderstanding. See above.
> 
> [...]
> > Checking the web for the differences btw RTL8102E and RTL8101E:
> > the RTL8102E claims to support receive-side scaling, is this implemented
> > somewhere in linux (aka NAPI?) ?
> 
> 1. RSS is available with Linux.
> 2. RSS is not related in any way or shape with NAPI.
> 3. RSS is not implemented in Realtek's driver yet.
Thanks. I found it.
> 
> > Can miss-detecting have a bad side-effects?
> 
> Some users have been turned into giant walking mushrooms.
I meant RTL8101E/RTL8102E have the same pci id but different features.
> 
> Not sure if they were comestible or not though.
If you kill their hardware, be sure they were not ;-)
> 
> > RTL8102E offers an option for non-EEPROM (=OTP) design. Can the driver
> > break the hardware ?
> 
> The driver is not supposed to break the hardware.
True, just that you know about that possibility. (_One Time Programming_)
> What does ethtool report for this device ? Does it still claim gigabit
> to be supported ?
Works correct,  as expected 10/100M.

Nice to know somebody cares! (Rest in pm)
Thanks for your work,
        Martin

