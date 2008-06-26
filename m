From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
	Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash,
	Another Problem)
Date: Thu, 26 Jun 2008 23:59:18 +0200
Message-ID: <20080626215918.GC2555@electric-eye.fr.zoreil.com>
References: <4861800B.90703@nscus.com> <20080625213142.GA29890@electric-eye.fr.zoreil.com> <48640535.2050000@nscus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Kasper Sandberg <lkml@metanurb.dk>,
	akpm@linux-foundation.org, linux-pci@vger.kernel.org
To: Michael Grollman <mgrollman@nscus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37433 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751939AbYFZV7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 17:59:32 -0400
Content-Disposition: inline
In-Reply-To: <48640535.2050000@nscus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(linux-pci Cced)

Michael Grollman <mgrollman@nscus.com> :
[...]
> Per instructions, I built an 2.6.26-rc8 system on the target Intel 
> hardware, and was able to re-recreate the intermittent failure of the 8201. 
>  When in failure mode, the lspci -vx' display of the pci registers of the 
> 8102 is as follows:
>
> 01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8101E PCI 
> Express Fast Ethernet controller (rev ff) (prog-if ff)
>    !!! Unknown header type 7f
> 00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> 10: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> 20: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> 30: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff

Bad mojo.

Can you reproduce the failure of the driver or lspci when you
boot the kernel with "pci=nommconf" (assuming CONFIG_PCI_MMCONFIG is
set in your .config) or "pci=conf1" (if CONFIG_PCI_DIRECT is instead).

[...]
> Let me know if there is anything else I can do to collect information on 
> this situation.

The (gzipped) content of your .config.

Kasper, could you check if you have the same symptoms with
2.6.26-rc8 (once your rendering is finished of course) ?

-- 
Ueimor
