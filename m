From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ksz884x: Fix section mismatch derived from
 pci_device_driver variable
Date: Mon, 03 Jan 2011 11:52:48 -0800 (PST)
Message-ID: <20110103.115248.179942629.davem@davemloft.net>
References: <1294020104-17124-1-git-send-email-sedat.dilek@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sedat.dilek@gmail.com
To: sedat.dilek@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294020104-17124-1-git-send-email-sedat.dilek@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sedat Dilek <sedat.dilek@googlemail.com>
Date: Mon,  3 Jan 2011 03:01:44 +0100

> WARNING: drivers/net/ksz884x.o(.data+0x18): Section mismatch in reference from the variable pci_device_driver to the function .init.text:pcidev_init()
> The variable pci_device_driver references
> the function __init pcidev_init()
> If the reference is valid then annotate the
> variable with __init* or __refdata (see linux/init.h) or name the variable:
> *_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,
> 
> This patch fixes the warning.
> 
> Tested with linux-next (next-20101231)
> 
> Signed-off-by: Sedat Dilek <sedat.dilek@gmail.com>

pcidev_init() should be marked __devinit instead of __init to fix this
bug.
