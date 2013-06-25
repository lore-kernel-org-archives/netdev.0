From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: sfc-next 2013-06-24
Date: Tue, 25 Jun 2013 16:12:30 -0700 (PDT)
Message-ID: <20130625.161230.91906672897765828.davem@davemloft.net>
References: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34803 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774Ab3FYXMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 19:12:32 -0400
In-Reply-To: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 24 Jun 2013 21:11:48 +0100

> The following changes since commit 37173488400704f1a05656616cd12baa9e03173b:
> 
>   bnx2x: Fix compilation with no IOV support (2013-06-24 01:47:47 -0700)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem
> 
> for you to fetch changes up to 636d73da27e83ce4882f8823f79063bb37980961:
> 
>   sfc: Improve test for IOMMU in use (2013-06-24 20:02:53 +0100)
> 
> 1. Make EEH recovery work when using legacy interrupts, from Alexandre
>    Rames.
> 
> 2. Enable accelerated RFS for VLAN-tagged flows, from Andy Lutomirski.
> 
> 3. Improve performance for non-TCP (and particularly UDP) traffic, which
>    regressed in 3.10 when we switched to always allocating paged RX
>    buffers.  Partly by Jon Cooper.
> 
> 4. Some minor bug fixes to IOMMU detection, timestamping capabilities,
>    and IRQ cleanup on the probe failure path.
> 
> I've dropped the RX skb cache, which improved some benchmarks but
> perhaps needs some reworking to be more generally useful.

Pulled, thanks Ben.
