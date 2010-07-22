From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: handle pci_iomap() errors
Date: Thu, 22 Jul 2010 14:11:45 -0700 (PDT)
Message-ID: <20100722.141145.116647591.davem@davemloft.net>
References: <1279713638-31567-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de, eric.dumazet@gmail.com,
	ben@decadent.org.uk, adobriyan@gmail.com, joe@perches.com,
	netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59038
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752107Ab0GVVL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 17:11:28 -0400
In-Reply-To: <1279713638-31567-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Wed, 21 Jul 2010 16:00:36 +0400

> pci_iomap() can fail, handle this case and return -ENOMEM from probe
> function.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied.

We seem to leak the iomaps if vortex_probe1() fails, feel free to fix
that too :-)
