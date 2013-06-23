From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 01/11] net/mlx4_en: Suppress page allocation
 failure warnings
Date: Sun, 23 Jun 2013 08:14:51 -0700
Message-ID: <1372000491.3301.25.camel@edumazet-glaptop>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
	  <1371757222-21412-2-git-send-email-amirv@mellanox.com>
	 <1371763689.3252.419.camel@edumazet-glaptop> <51C6B602.20703@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:62549 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148Ab3FWPOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 11:14:54 -0400
Received: by mail-ee0-f45.google.com with SMTP id c1so5529446eek.4
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 08:14:53 -0700 (PDT)
In-Reply-To: <51C6B602.20703@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-23 at 11:46 +0300, Amir Vadai wrote:

> But mlx4_en_alloc_frags() is on the data path, and many warnings there
> when the system is already stressed and without memory is bad.
> Besides the warnings, this error flow is handled, and
> mlx4_en_en_fill_rx_buffers() will handle the ENOMEM.
> 
> > 
> > I think I did a patch doing fallback to order-1 and order-0 allocations
> Current code has, as I said above, a fallback to reduce the rx ring size
> when memory is stressed.

Well, it should not do that, and instead use GFP_KERNEL.

>  Do you suggest to use smaller fragments instead
> (or in addition)?
> Can you send me a link to the patch?
> 

Sure, I'll respin it.
