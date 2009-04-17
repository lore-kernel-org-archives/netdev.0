From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macb: Kconfig net device compat fixup
Date: Fri, 17 Apr 2009 00:54:51 -0700 (PDT)
Message-ID: <20090417.005451.215477692.davem@davemloft.net>
References: <1239953045.2837.58.camel@linux-51e8.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hskinnemoen@atmel.com, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bn@niasdigital.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43931
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751400AbZDQHzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 03:55:00 -0400
In-Reply-To: <1239953045.2837.58.camel@linux-51e8.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Nizette <bn@niasdigital.com>
Date: Fri, 17 Apr 2009 17:24:05 +1000

> The macb driver hasn't been updated to use net_device_ops and as such
> should select COMPAT_NET_DEV_OPS to avoid build breakage.
> 
> Of course really macb should be updated but in the mean time, this at
> least avoid randconfig problems.
> 
> Signed-off-by: Ben Nizette <bn@niasdigital.com>

There's about 26 drivers that fall into this category, it's senseless
to pepper the tree over with this kind of annotation that we'll just
release come next release.

We do have enough drivers converted that powerpc, sparc64, and x86
allmodconfig and allyesconfig builds pass even with the compat option
disabled.

And I think the others can just cope with this for now.

Actually, in the net-next-2.6 tree this driver has in fact been
converted :-)
