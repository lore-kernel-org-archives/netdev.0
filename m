From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: add amd8131 to "write reorder" chipsets
Date: Fri, 07 Jul 2006 13:57:24 -0700 (PDT)
Message-ID: <20060707.135724.26300161.davem@davemloft.net>
References: <20060707185831.GC22636@tuxdriver.com>
	<20060707.121220.99179918.davem@davemloft.net>
	<44AEC252.70209@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:45956
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751230AbWGGU44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 16:56:56 -0400
To: auke-jan.h.kok@intel.com
In-Reply-To: <44AEC252.70209@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>
Date: Fri, 07 Jul 2006 13:21:38 -0700

> Moreover, since e1000 suffers from reordering/write-combining
> problems on the 8132, I'm starting to see an (ugly) pattern here. I
> didn't know that tg3 has a whole blacklist for this, could this
> affect other network cards as well?

The tg3 is probably more susceptible to this problem because of
how it uses a software structure in memory for interrupt status and
RX/TX descriptor table head/tail indexes.

Whereas the e1000 always has to synchronize with MMIO register reads
to get interrupt status and the indexes.
