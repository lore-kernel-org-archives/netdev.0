From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] bnx2: Fix IRQ failures during kdump.
Date: Sun, 30 May 2010 11:44:33 +0200
Message-ID: <87k4qlzptq.fsf@basil.nowhere.org>
References: <C27F8246C663564A84BB7AB3439772421B78147573@IRVEXCHCCR01.corp.ad.broadcom.com>
	<20100529.160527.108793180.davem@davemloft.net>
	<20100530012401.GC9132@parisc-linux.org>
	<20100529.204906.55850229.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matthew@wil.cx, mchan@broadcom.com, grundler@parisc-linux.org,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20100529.204906.55850229.davem@davemloft.net> (David Miller's message of "Sat\, 29 May 2010 20\:49\:06 -0700 \(PDT\)")
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
>
> Basically all of these issues tend to be about the fact that unlike on
> a normal boot, after a kexec an intermediate PCI reset has not occured.

This could be fixed, assuming the system has AER capability ...

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
