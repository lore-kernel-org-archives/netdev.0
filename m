From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: Drop bogus __init annotation from
 vsock_init_tables()
Date: Thu, 25 Apr 2013 04:22:43 -0400 (EDT)
Message-ID: <20130425.042243.666546906391472969.davem@davemloft.net>
References: <1366796455-2520-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acking@vmware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366796455-2520-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 24 Apr 2013 11:40:55 +0200

> If gcc (e.g. 4.1.2) decides not to inline vsock_init_tables(), this will
> cause a section mismatch:
> 
> WARNING: net/vmw_vsock/vsock.o(.text+0x1bc): Section mismatch in reference from the function __vsock_core_init() to the function .init.text:vsock_init_tables()
> The function __vsock_core_init() references
> the function __init vsock_init_tables().
> This is often because __vsock_core_init lacks a __init
> annotation or the annotation of vsock_init_tables is wrong.
> 
> This may cause crashes if VSOCKETS=y and VMWARE_VMCI_VSOCKETS=m.
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied.
