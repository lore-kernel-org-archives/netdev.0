From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] rtnetlink: Use nlmsg type RTM_NEWNEIGH from dflt
 fdb dump
Date: Sat, 03 Nov 2012 15:27:54 -0400 (EDT)
Message-ID: <20121103.152754.2092368421723006557.davem@davemloft.net>
References: <20121102022310.2692.60718.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58124 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab2KCT1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 15:27:55 -0400
In-Reply-To: <20121102022310.2692.60718.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Thu, 01 Nov 2012 19:23:10 -0700

> Change the dflt fdb dump handler to use RTM_NEWNEIGH to
> be compatible with bridge dump routines.
> 
> The dump reply from the network driver handlers should
> match the reply from bridge handler. The fact they were
> not in the ixgbe case was effectively a bug. This patch
> resolves it.
> 
> Applications that were not checking the nlmsg type will
> continue to work. And now applications that do check
> the type will work as expected.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
