From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: fix crash while accessing
 second slave ethernet interface
Date: Wed, 08 Jul 2015 16:09:59 -0700 (PDT)
Message-ID: <20150708.160959.1934913240632137548.davem@davemloft.net>
References: <1436274039-20941-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38279 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbbGHXKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:10:00 -0400
In-Reply-To: <1436274039-20941-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Tue, 7 Jul 2015 18:30:39 +0530

> When cpsw's number of slave is set to 1 in device tree and while
> accessing second slave ndev and priv in cpsw_tx_interrupt(),
> there is a kernel crash. This is due to cpsw_get_slave_priv()
> not verifying number of slaves while retriving netdev priv and
> returns a invalid memory region. Fixing the issue by introducing
> number of slave check in cpsw_get_slave_priv() and
> cpsw_get_slave_ndev().
...
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> Cc: <stable@vger.kernel.org> # v3.8+

Applied, thanks.
