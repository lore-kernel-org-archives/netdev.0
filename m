From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: More Shutdown revisions
Date: Mon, 27 Jan 2014 13:13:40 -0800 (PST)
Message-ID: <20140127.131340.2237936899214374913.davem@davemloft.net>
References: <1390835518-29652-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754463AbaA0VNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 16:13:41 -0500
In-Reply-To: <1390835518-29652-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <yuvalmin@broadcom.com>
Date: Mon, 27 Jan 2014 17:11:58 +0200

> Submission d9aee59 "bnx2x: Don't release PCI bars on shutdown" separated
> the PCI remove and shutdown flows, but pci_disable_device() is still
> being called on both.
> As a result, a dev_WARN_ONCE will be hit during shutdown for every bnx2x
> VF probed on a hypervisor (as its shutdown callback will be called and later
> pci_disable_sriov() will call its remove callback).
> 
> This calls the pci_disable_device() only on the remove flow.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>

Applied.
