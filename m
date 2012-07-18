From: David Miller <davem@davemloft.net>
Subject: Re: pull request: sfc-next 2012-07-17
Date: Wed, 18 Jul 2012 09:10:10 -0700 (PDT)
Message-ID: <20120718.091010.2180226373071597034.davem@davemloft.net>
References: <1342544740.2698.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842Ab2GRQKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:10:11 -0400
In-Reply-To: <1342544740.2698.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 17 Jul 2012 18:05:40 +0100

> The following changes since commit 141e369de698f2e17bf716b83fcc647ddcb2220c:
> 
>   xfrm: Initialize the struct xfrm_dst behind the dst_enty field (2012-07-14 00:29:12 -0700)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem
> 
> (commit c2dbab39db1c3c2ccbdbb2c6bac6f07cc7a7c1f6)
> 
> 1. Fix potential badness when running a self-test with SR-IOV enabled.
> 2. Fix calculation of some interface statistics that could run backward.
> 3. Miscellaneous cleanup.

Looks good, pulled, thanks Ben.

Out of curiosity, why the conversion to the generic DMA interfaces?
Do you plan on using something uniquely provided by them vs. the PCI
specific DMA interfaces (ability to specify GFP flags, stuff like
that) or do you really plan on having non-PCI devices in the future?
