From: David Miller <davem@davemloft.net>
Subject: Re: [patch 28/28] Introduce strtol_check_range()
Date: Fri, 10 Aug 2007 15:39:17 -0700 (PDT)
Message-ID: <20070810.153917.54189151.davem@davemloft.net>
References: <200708102112.l7ALCAd9009463@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, satyam@infradead.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38175
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752214AbXHJWjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:39:16 -0400
In-Reply-To: <200708102112.l7ALCAd9009463@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:12:10 -0700

> From: Satyam Sharma <satyam@infradead.org>
> 
> Callers (especially "store" functions for sysfs or configfs attributes)
> that want to convert an input string to a number may often also want to
> check for simple input sanity or allowable range.  strtol10_check_range()
> of netconsole does this, so extract it out into lib/vsprintf.c, make it
> generic w.r.t.  base, and export it to the rest of the kernel and modules.
> 
> [akpm@linux-foundation.org: cleanups]
> Signed-off-by: Satyam Sharma <satyam@infradead.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

This depends upon 27/28, which needs some fixes, so please
resubmit once that patch is cured.

Thanks.
