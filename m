From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/10] Make XPS usable within ixgbe
Date: Thu, 10 Jan 2013 22:47:31 -0800 (PST)
Message-ID: <20130110.224731.1485226572082498176.davem@davemloft.net>
References: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	therbert@google.com, ycai@google.com, eric.dumazet@gmail.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702Ab3AKGre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 01:47:34 -0500
In-Reply-To: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 10 Jan 2013 10:56:03 -0800

> The following patch series makes it so that the ixgbe driver can support
> ATR even when the number of queues is less than the number of CPUs.  To do
> this I have updated the kernel to support letting drivers set their own XPS
> configuration.  To do this it was necessary to move the code out of the
> sysfs specific code and into the dev specific regions.
> 
> It has been almost 6 months since the last time I released these patches.  I
> have been meaning to get back to them but I just haven't had a chance to get
> this work done until recently.
> 
> Only the core net patches are meant for acceptance at this time.  I will
> submit the ixgbe patches through Jeff Kirsher's tree.  For this reason I have
> tagged the ixgbe related patches as RFC.

Patches 1-5 look fine, all applied, thanks.
