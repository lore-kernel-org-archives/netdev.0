From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: RTL8169 driver no longer functioning with 8111b
Date: Tue, 13 May 2008 22:51:40 +0200
Message-ID: <20080513205140.GA11808@electric-eye.fr.zoreil.com>
References: <4828D529.3060201@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: ackman <ackman@gtf.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:56521 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758948AbYEMVOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 17:14:08 -0400
Content-Disposition: inline
In-Reply-To: <4828D529.3060201@gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ackman <ackman@gtf.org> :
> I've spent the better part of a day researching this to no avail.  I run 
> Gentoo on an Abit AB9 PRO P965 board.  It has two onboard ports for a 
> Realtek 8111B Gigabit interface.  I have been running 2.6.23-gentoo-r8 (I 
> think) kernel sources.

uname -a should help figuring the exact version.

[...]
> being turn on.  It just mysteriously has stopped being alive.  lspci shows 
> the devices, their given eth0 and eth1 as usual, I can disable them in the 
> bios and watch Linux recognize they're missing, but still I can't for the 
> life of me get them to act properly.  I've tried turning off ACPI, I've 
> tried 2.6.24-gentoo-r7 kernel, I've tried the Realtek driver source for 
> r8168.  ACPI support was the only thing I can think of that has been a 
> major change on the system anytime recently. 
> Any suggestions would be helpful.

Can you give noapic, pci=nomsi, pci=nommconf a try and send both
'lspci -H1 -vvxx' and 'lspci -vvxx' output ?

The 'XID' line produced by dmesg would be welcome too.

-- 
Ueimor
