From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: "uli526x: I/O base is zero"
Date: Sat, 4 Nov 2006 23:14:22 +0100
Message-ID: <20061104221422.GA27752@electric-eye.fr.zoreil.com>
References: <20061104182640.11073.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:22415 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S965715AbWKDWQS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Nov 2006 17:16:18 -0500
To: linux@horizon.com
Content-Disposition: inline
In-Reply-To: <20061104182640.11073.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

linux@horizon.com <linux@horizon.com> :
[...]
> uli526x: uli526x_init_one() 0
> ACPI: PCI interrupt 0000:00:12.0[A]->GFI 20(level,low)->IRQ 50
> uli526x: I/O base is zero

The PCI base address register used by the device is not set. Weird.

<wet finger>
It may be that the driver does not use the adequate BAR (gross).
lspci -vx may give some hint. Otherwise ACPI, bios or PCI bridge
are the usual suspects.  
</wet finger>

-- 
Ueimor
