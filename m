From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [PATCH v3 1/2] 8139too: Fix the lack of
 pci_disable_device
Date: Mon, 22 Dec 2014 16:32:14 -0500 (EST)
Message-ID: <20141222.163214.68321788009034151.davem@davemloft.net>
References: <1419208132-23657-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: baijiaju1990@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43683 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755293AbaLVVcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 16:32:16 -0500
In-Reply-To: <1419208132-23657-1-git-send-email-baijiaju1990@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jia-Ju Bai <baijiaju1990@163.com>
Date: Mon, 22 Dec 2014 08:28:52 +0800

> For linux-3.18.0
> When pci_request_regions is failed in rtl8139_init_board, pci_disable_device 
> is not called to disable the device which are enabled by pci_enable_device, 
> because of disable_dev_on_err is not assigned 1.
> This patch fix this problem.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

Applied.
