From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: RealTek 8169 support question
Date: Sat, 11 Aug 2007 00:23:46 +0200
Message-ID: <20070810222346.GA9042@electric-eye.fr.zoreil.com>
References: <46BCD853.1010801@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev ML <netdev@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:51256 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765603AbXHJWY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 18:24:57 -0400
Content-Disposition: inline
In-Reply-To: <46BCD853.1010801@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Lever <chuck.lever@oracle.com> :
[...]
> I just bought a new Jetway mainboard with a pair of RTL 8169 NICs. 

Mini-ITX J7F4 ?

> After installing Fedora 7, and upgrading to 2.6.22.1-41.fc7, I still 
> can't get either of the NICs to recognize a link beat from my switch.
> 
> lspci -v output:
> 
> 00:09.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
> RTL-8110SC/8169SC Gigabit Ethernet (rev 10)
>         Subsystem: Jetway Information Co., Ltd. Unknown device 10ec
>         Flags: bus master, 66MHz, medium devsel, latency 32, IRQ 18
>         I/O ports at ee00 [size=256]
>         Memory at fdffe000 (32-bit, non-prefetchable) [size=256]
>         [virtual] Expansion ROM at 10020000 [disabled] [size=64K]
>         Capabilities: [dc] Power Management version 2
[...]
> I assume "Unknown device" indicates that the driver doesn't recognize 
> the model string?

Not exactly. The driver uses the PCI Vendor ID/Device ID Configuration
registers to identify the chipset. lspci used the same information to
identify a "Realtek... RTL-8110SC/8169SC...". It is a known device.
The driver does not care about the Subsystem ID ("10ec" above) so there
is nothing to worry about here.

> Thanks in advance for any advice.

Have your tried 2.6.23-git-latest or at least a post 2.6.23-rc1 kernel ?

-- 
Ueimor
