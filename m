From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] bnx2: Fix IRQ failures during kdump.
Date: Sun, 30 May 2010 11:43:32 +0200
Message-ID: <87ocfxzpvf.fsf@basil.nowhere.org>
References: <1275103462-8527-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:51989 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245Ab0E3Jnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 05:43:35 -0400
In-Reply-To: <1275103462-8527-1-git-send-email-mchan@broadcom.com> (Michael Chan's message of "Fri\, 28 May 2010 20\:24\:22 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael Chan" <mchan@broadcom.com> writes:

> When switching from the crashed kernel to the kdump kernel without going
> through PCI reset, IRQs may not work if a different IRQ mode is used on

PCIe with AER actually does support per link root port reset
(e.g. used for AER)

I've been wondering for some time if kexec should not simply
use that to reset all the devices, instead of addings hacks
around this to all drivers.

That would fix your problems too, right?

The question is just if AER is widely enough supported for this.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
