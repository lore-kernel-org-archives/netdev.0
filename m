From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/3] Replace wmb()/rmb() with
 dma_wmb()/dma_rmb() where appropriate
Date: Wed, 08 Apr 2015 12:15:31 -0400 (EDT)
Message-ID: <20150408.121531.264247541235587759.davem@davemloft.net>
References: <20150407235324.1574.63255.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39023 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754632AbbDHQPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 12:15:33 -0400
In-Reply-To: <20150407235324.1574.63255.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Tue, 07 Apr 2015 16:55:08 -0700

> This is a start of a side project cleaning up the drivers that can make use
> of the dma_wmb and dma_rmb calls.  The general idea is to start removing
> the unnecessary wmb/rmb calls from a number of drivers and to make use of
> the lighter weight dma_wmb/dma_rmb calls as this should allow for an
> overall improvement in performance as each barrier can cost a significant
> number of cycles and on architectures such as x86 this is unnecessary.
> 
> These changes are what I would consider low hanging fruit.  The likelihood
> of the changes introducing an error should be low since the use of the
> barriers in these cases are fairly obvious.

Series applied, thanks.
