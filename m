From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: Avoid accessing eq object in
 be_msix_register routine, when i < 0.
Date: Fri, 18 Dec 2015 15:51:18 -0500 (EST)
Message-ID: <20151218.155118.779504200158181032.davem@davemloft.net>
References: <1450383050-25106-1-git-send-email-venkatkumar.duvvuru@avagotech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, venkatkumar.duvvuru@vger.kernel.org
To: venkatkumar.duvvuru@avagotech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964980AbbLRUvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 15:51:19 -0500
In-Reply-To: <1450383050-25106-1-git-send-email-venkatkumar.duvvuru@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Duvvuru <venkatkumar.duvvuru@avagotech.com>
Date: Fri, 18 Dec 2015 01:40:50 +0530

> When the first request_irq fails in be_msix_register, i value
> would be zero. The current code decrements the i value and
> accesses the eq object without validating the decremented
> "i" value. This can cause an "invalid memory address access"
> violation.
> 
> This patch fixes the problem by accessing the eq object after
> validating the "i" value.
> 
> Signed-off-by: Venkat Duvvuru <venkatkumar.duvvuru@avagotech.com>

Applied, thank you.
