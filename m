From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] hyperv: Fix a compiler warning in netvsc_send()
Date: Tue, 16 Apr 2013 15:11:41 -0400 (EDT)
Message-ID: <20130416.151141.1928940532005718606.davem@davemloft.net>
References: <1366139031-12518-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753837Ab3DPTLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 15:11:46 -0400
In-Reply-To: <1366139031-12518-1-git-send-email-haiyangz@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue, 16 Apr 2013 12:03:51 -0700

> Fixed: warning: cast from pointer to integer of different size
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

If you're coding pointers into request IDs you better make that
explicit and add lots of comments explaining why that's OK and
why it's going to work fine in these circumstances.

I'm not applying this patch, it just makes a bad situation even
worse.  Either your request IDs are 64-bit or they are not, it
can't be both.
