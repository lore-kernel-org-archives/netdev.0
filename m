From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4 0/3] xen-netback: synchronisation between core
 driver and netback
Date: Tue, 12 Aug 2014 14:42:10 -0700 (PDT)
Message-ID: <20140812.144210.146081051768163876.davem@davemloft.net>
References: <1407840488-20026-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, zoltan.kiss@citrix.com,
	david.vrabel@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbaHLVmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 17:42:11 -0400
In-Reply-To: <1407840488-20026-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Tue, 12 Aug 2014 11:48:05 +0100

> The zero-copy netback has far more interactions with core network driver than
> the old copying backend. One significant thing is that netback now relies on
> a callback from core driver to correctly release resources.
> 
> However correct synchronisation between core driver and netback is missing.
> Currently netback relies on a loop to wait for core driver to release
> resources. This is proven not enough and erroneous recently, partly due to code
> structure, partly due to missing synchronisation. Short-live domains like
> OpenMirage unikernels can easily trigger race in backend, rendering backend
> unresponsive.
> 
> This patch series aims to slove this issue by introducing proper
> synchronisation between core driver and netback.

Series applied.
