From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic - Fix scheduling while atomic bug
Date: Thu, 27 Sep 2012 19:26:02 -0400 (EDT)
Message-ID: <20120927.192602.1354851114513597606.davem@davemloft.net>
References: <20120925175212.GA1324@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	jitendra.kalsaria@qlogic.com, john.r.fastabend@intel.com
To: Narendra_K@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952Ab2I0X0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 19:26:09 -0400
In-Reply-To: <20120925175212.GA1324@fedora-17-guest.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Narendra_K@Dell.com>
Date: Tue, 25 Sep 2012 10:53:19 -0700

> From: Narendra K <narendra_k@dell.com>
> 
> In the device close path, 'qlcnic_fw_destroy_ctx' and
> 'qlcnic_poll_rsp' call msleep. But  'qlcnic_fw_destroy_ctx' and
> 'qlcnic_poll_rsp' are called with 'adapter->tx_clean_lock' spin lock
> held resulting in scheduling while atomic bug causing the following
> trace.
> 
> I observed that the commit 012dc19a45b2b9cc2ebd14aaa401cf782c2abba4
> from John Fastabend addresses a similar issue in ixgbevf driver.
> Adopting the same approach used in the commit, this patch uses mdelay
> to address the issue.
 ...
> Signed-off-by: Narendra K <narendra_k@dell.com>

Applied, thanks.

In the future please format your Subject lines for patches as
"subsytem: Description."  instead of this "subsystem - Description."
layout.

Thanks.
