From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Don't release PCI bars on shutdown
Date: Wed, 15 Jan 2014 16:49:13 -0800 (PST)
Message-ID: <20140115.164913.281764267072238181.davem@davemloft.net>
References: <1389780330-6927-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43063 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbaAPAtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 19:49:13 -0500
In-Reply-To: <1389780330-6927-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <yuvalmin@broadcom.com>
Date: Wed, 15 Jan 2014 12:05:30 +0200

> The bnx2x driver in its pci shutdown() callback releases its pci bars (in the
> same manner it does during its pci remove() callback).
> During a system reboot while VFs are enabled, its possible for the VF's remove
> to be called (as a result of pci_disable_sriov()) after its shutdown callback
> has already finished running; This will cause a paging request fault as the VF
> tries to access the pci bar which it has previously released, crashing the
> system.
> 
> This patch further differentiates the shutdown and remove callbacks, preventing the
> pci release procedures from being called during shutdown.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>

Applied, thanks.
