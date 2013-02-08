From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] XSA-39 CVE-2013-021[67]: Linux netback DoS via
 malicious guest ring.
Date: Thu, 07 Feb 2013 23:31:07 -0500 (EST)
Message-ID: <20130207.233107.1094455509765442729.davem@davemloft.net>
References: <1360230078.32479.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56641 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759696Ab3BHEbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 23:31:08 -0500
In-Reply-To: <1360230078.32479.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Thu, 7 Feb 2013 09:41:18 +0000

> The Xen netback implementation contains a couple of flaws which can
> allow a guest to cause a DoS in the backend domain, potentially
> affecting other domains in the system.
> 
> CVE-2013-0216 is a failure to sanity check the ring producer/consumer
> pointers which can allow a guest to cause netback to loop for an
> extended period preventing other work from occurring.
> 
> CVE-2013-0217 is a memory leak on an error path which is guest
> triggerable.
> 
> The following series contains the fixes for these issues, as previously
> included in Xen Security Advisory 39:
> http://lists.xen.org/archives/html/xen-announce/2013-02/msg00001.html
> 
> Changes in v2:
>  - Typo and block comment format fixes 
>  - Added stable Cc

Applied, please don't add stable CC:'s to networking patches, instead
ask me to queue it up to my -stable todo pile instead.

I don't like it when patches instantly be submitted to -stable when
they hit Linus's tree, I'd rather it soak upstream for a week or two
instead.  That's why I do it this way.

Thanks.
