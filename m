From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: sfc-next 2013-03-11
Date: Tue, 12 Mar 2013 05:15:39 -0400 (EDT)
Message-ID: <20130312.051539.685625527945111634.davem@davemloft.net>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	scrum-linux@solarflare.com, levans@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754756Ab3CLJP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 05:15:28 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 11 Mar 2013 19:33:20 +0000

>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem
> 
> (commit 1648a23fa159e5c433aac06dc5e0d9db36146016)
> 
> 1. Merge sfc changes (only) accepted for 3.9.
> 
> 2. PTP improvements from Laurence Evans.
> 
> 3. Overhaul of RX buffer management:
> - Always allocate pages, and enable scattering where possible
> - Fit as many buffers as will fit into a page, rather than limiting to 2
> - Introduce recycle rings to reduce the need for IOMMU mapping and
>   unmapping
> 
> 4. PCI error recovery (AER and EEH) implementation.
> 
> 5. Fix a bug in RX filter replacement.
> 
> 6. Fix configuration with 1 RX queue in the PF and multiple RX queues in
> VFs.

Pulled, thanks Ben.
