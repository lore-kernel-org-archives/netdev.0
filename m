From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: drivers/net/r6040.c warnings on x86_64
Date: Tue, 27 Nov 2007 23:06:01 -0800
Message-ID: <20071127230601.fbb60024.akpm@linux-foundation.org>
References: <20071127204536.61bf7921.akpm@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Sten Wang <sten.wang@rdc.com.tw>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34595 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750761AbXK1HGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 02:06:06 -0500
In-Reply-To: <20071127204536.61bf7921.akpm@google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Nov 2007 20:45:36 -0800 Andrew Morton <akpm@google.com> wrote:

> drivers/net/r6040.c: In function 'rx_buf_alloc':
> drivers/net/r6040.c:262: warning: passing argument 2 of 'pci_map_single' makes pointer from integer without a cast
> drivers/net/r6040.c: In function 'r6040_up':
> drivers/net/r6040.c:631: warning: cast from pointer to integer of different size
> drivers/net/r6040.c:632: warning: cast to pointer from integer of different size
> drivers/net/r6040.c:637: warning: cast from pointer to integer of different size
> drivers/net/r6040.c:638: warning: cast to pointer from integer of different size
> 
> can we fix these please?

it breaks the sparc64 build too

drivers/net/r6040.c: In function `rx_buf_alloc':
drivers/net/r6040.c:262: warning: passing arg 2 of `pci_map_single' makes pointer from integer without a cast
drivers/net/r6040.c:262: warning: passing arg 2 of `pci_map_single' makes pointer from integer without a cast
drivers/net/r6040.c:262: warning: passing arg 2 of `pci_map_single' makes pointer from integer without a cast
drivers/net/r6040.c:262: warning: passing arg 2 of `pci_map_single' makes pointer from integer without a cast
drivers/net/r6040.c:262: warning: passing arg 2 of `pci_map_single' makes pointer from integer without a cast
drivers/net/r6040.c:262: warning: passing arg 2 of `pci_map_single' makes pointer from integer without a cast
drivers/net/r6040.c: In function `r6040_up':
drivers/net/r6040.c:631: warning: cast from pointer to integer of different size
drivers/net/r6040.c:631: warning: cast from pointer to integer of different size
drivers/net/r6040.c:631: warning: cast from pointer to integer of different size
drivers/net/r6040.c:631: warning: cast from pointer to integer of different size
drivers/net/r6040.c:631: warning: cast from pointer to integer of different size
drivers/net/r6040.c:631: warning: cast from pointer to integer of different size
drivers/net/r6040.c:632: error: implicit declaration of function `virt_to_bus'
drivers/net/r6040.c:632: warning: cast to pointer from integer of different size
drivers/net/r6040.c:637: warning: cast from pointer to integer of different size
drivers/net/r6040.c:637: warning: cast from pointer to integer of different size
drivers/net/r6040.c:637: warning: cast from pointer to integer of different size
drivers/net/r6040.c:637: warning: cast from pointer to integer of different size
drivers/net/r6040.c:637: warning: cast from pointer to integer of different size
drivers/net/r6040.c:637: warning: cast from pointer to integer of different size
drivers/net/r6040.c:638: warning: cast to pointer from integer of different size
