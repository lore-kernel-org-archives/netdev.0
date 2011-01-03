From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ksz884x: Fix section mismatch derived from
 pcidev_init()
Date: Mon, 03 Jan 2011 13:27:50 -0800 (PST)
Message-ID: <20110103.132750.241921691.davem@davemloft.net>
References: <1294088818-2903-1-git-send-email-sedat.dilek@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sedat.dilek@gmail.com
To: sedat.dilek@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294088818-2903-1-git-send-email-sedat.dilek@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sedat Dilek <sedat.dilek@googlemail.com>
Date: Mon,  3 Jan 2011 22:06:58 +0100

> This fixes the following warning:
> 
> WARNING: drivers/net/ksz884x.o(.data+0x18): Section mismatch in reference from the variable pci_device_driver to the function .init.text:pcidev_init()
> The variable pci_device_driver references
> the function __init pcidev_init()
> If the reference is valid then annotate the
> variable with __init* or __refdata (see linux/init.h) or name the variable:
> *_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,
> 
> Tested with linux-next (next-20101231)
> 
> Signed-off-by: Sedat Dilek <sedat.dilek@gmail.com>

Applied.
