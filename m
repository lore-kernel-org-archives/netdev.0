From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/40] wimax: declarations for the in-kernel WiMAX API
Date: Fri, 05 Dec 2008 22:37:54 -0800 (PST)
Message-ID: <20081205.223754.166106378.davem@davemloft.net>
References: <cover.1228503076.git.inaky@linux.intel.com>
	<5fc227cf5709b01802959712ac23f519e65d4801.1228503077.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org, greg@kroah.com
To: inaky@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56305
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750950AbYLFGhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2008 01:37:54 -0500
In-Reply-To: <5fc227cf5709b01802959712ac23f519e65d4801.1228503077.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Fri,  5 Dec 2008 10:54:55 -0800

> Declares the main data types and calls for the drivers to integrate
> into the WiMAX stack. Provides usage documentation.
> 
> Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>

This does:

+#include <linux/wimax.h>

which doesn't even exist yet.

I understand what you're trying to do, chop things up into manageable
pieces.  But this is taking it way too far.

It's totally impossible to review this patch on it's own, because none
of the necessary context exists at this point in the patch series.

I read this and wanted to know what enum wimax_st was, but that is
impossible to find because of this problem.

40 patches is, a lot, and I've now gone through this both in my inbox
and in my patch queue at patchwork.ozlabs.org 3 times.

You need to compact this a lot more if you want people to
review it without losing an entire day of their lives doing
so.

Thanks.
