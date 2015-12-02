From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH 3/6] net: thunderx: Increase transmit queue length
Date: Wed, 2 Dec 2015 18:27:14 +0530
Message-ID: <CA+sq2CfSNBQaQnw32tu4ZcZYLd6ybVZ3Ka5Oz=s1YUNegZpd-A@mail.gmail.com>
References: <y@samsung.com>
	<1448961223-41888-4-git-send-email-sunil.kovvuri@gmail.com>
	<01d101d12c46$2de43b40$89acb1c0$@samsung.com>
	<1448983985.25582.35.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+sq2Ce9oH-kCDO8hK_wX+ZZdXyyBuT4V2bt5Ab+2=pEX+BO+w@mail.gmail.com>
	<00cb01d12ce0$9f090540$dd1b0fc0$@samsung.com>
	<00eb01d12cec$a32aa500$e97fef00$@samsung.com>
	<013301d12cfd$0c958a90$25c09fb0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>
To: Pavel Fedin <p.fedin@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:33034 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756199AbbLBM5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 07:57:16 -0500
In-Reply-To: <013301d12cfd$0c958a90$25c09fb0$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>After getting it working in guest i tried to apply it to host. With total of 128 virtual functions (= 128 interfaces) it does not work at all.
> Even after bumping cma region size to insane value of 2GB more than half of interfaces still failed to allocate queues.
> And after setting cma=3G i could not mount my rootfs.

Here what you are saying is half of the interfaces were initialized
succesfully and rest didn't.
So this issue is not something which is introduced by this patch.

> Can we use some other method for allocating queues, which would not require such a huge coherent pool?
There are so many drivers which use dma_alloc_coherent() directly or
via pci_alloc_consistent() to
allocate memory. How many drivers should we modify.
