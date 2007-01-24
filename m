From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: 2.6.20-rc4-mm1: PCI=n: drivers/net/3c59x.c compile error
Date: Wed, 24 Jan 2007 17:12:22 +0300
Message-ID: <45B76946.1070009@ru.mvista.com>
References: <20070111222627.66bb75ab.akpm@osdl.org> <20070124135354.GI17836@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751487AbXAXOMc@vger.kernel.org>
In-Reply-To: <20070124135354.GI17836@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Adrian Bunk wrote:
> 3x59x-fix-pci-resource-management.patch causes the following compile 
> error with CONFIG_PCI=n:
> 
> <--  snip  -->
> 
> ...
>   CC      drivers/net/3c59x.o
> /home/bunk/linux/kernel-2.6/linux-2.6.20-rc4-mm1/drivers/net/3c59x.c: In function 'vortex_init_one':
> /home/bunk/linux/kernel-2.6/linux-2.6.20-rc4-mm1/drivers/net/3c59x.c:961: error: implicit declaration of function 'pci_request_regions'
> /home/bunk/linux/kernel-2.6/linux-2.6.20-rc4-mm1/drivers/net/3c59x.c:985: error: implicit declaration of function 'pci_release_regions'
> make[3]: *** [drivers/net/3c59x.o] Error 1

    Grr, at at the same time it's happy with pci_enable_device().
    I'd say the problem is in <linux/pci.h>,  not in the patch.

> cu
> Adrian

MBR, Sergei
