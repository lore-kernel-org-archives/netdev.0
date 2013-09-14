From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] alx: remove redundant D0 power state set
Date: Fri, 13 Sep 2013 20:12:17 -0400 (EDT)
Message-ID: <20130913.201217.240090962278382294.davem@davemloft.net>
References: <1378865220-9368-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org,
	guohanjun@huawei.com
To: wangyijing@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59714 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755295Ab3INAMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 20:12:18 -0400
In-Reply-To: <1378865220-9368-1-git-send-email-wangyijing@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 11 Sep 2013 10:07:00 +0800

> Pci_enable_device_mem() will set device power state to D0,
> so it's no need to do it again in alx_probe().
> Also remove redundant PM Cap find code, because pci core
> has been saved the pci device pm cap value.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>

Applied, thank you.
