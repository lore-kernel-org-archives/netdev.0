From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: Fix race between dev_open() and
 register_netdev()
Date: Wed, 15 Aug 2012 15:10:54 -0700 (PDT)
Message-ID: <20120815.151054.740192419844791866.davem@davemloft.net>
References: <1344960816-12022-1-git-send-email-steve@purestorage.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org
To: steve@purestorage.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753183Ab2HOWKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 18:10:55 -0400
In-Reply-To: <1344960816-12022-1-git-send-email-steve@purestorage.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <steve@purestorage.com>
Date: Tue, 14 Aug 2012 17:13:36 +0100

> dev_open() can complete before register_netdev() returns.
> Fix vmxnet3_probe_device() to support this.
> 
> Signed-off-by: Steve Hodgson <steve@purestorage.com>

Applied, thanks Steve.
