From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cnic: Fix mmap regression.
Date: Fri, 29 Jun 2012 15:34:25 -0700 (PDT)
Message-ID: <20120629.153425.24594752441419170.davem@davemloft.net>
References: <1340998365-15753-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38728 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391Ab2F2We2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 18:34:28 -0400
In-Reply-To: <1340998365-15753-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 29 Jun 2012 12:32:45 -0700

> commit 1f85d58cdf15354a7120fc9ccc9bb9c45b53af88
>     cnic: Remove uio mem[0].
> 
> introduced a regression as older versions of userspace app still rely
> on this mmap.  Restore the mmap functionality and get the base address
> from pci_resource_start() as the nedev->base_addr has been deprecated for
> PCI devices.
> 
> Update version to 2.5.12.
> 
> Signed-off-by: Michael Chan <mchan@broadocm.com>

I really couldn't believe what you guys were doing in the original
commit, but I decided to let you do stupid things and find out the
hard way that removing any user visible interface is basically
impossible.

Applied, thanks.
