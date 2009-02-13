From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] sfc: modify allocation error message
Date: Thu, 12 Feb 2009 16:45:08 -0800 (PST)
Message-ID: <20090212.164508.199710443.davem@davemloft.net>
References: <200902112127.n1BLRZSA031950@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, travis@sgi.com, bhutchings@solarflare.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48409
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754448AbZBMApO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:45:14 -0500
In-Reply-To: <200902112127.n1BLRZSA031950@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 11 Feb 2009 13:27:34 -0800

> Change error message when alloc_cpumask_var fails.
> 
> Signed-off-by: Mike Travis <travis@sgi.com>
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

This has to go into whatever tree adds the alloc_cpumask_var()
call to this function, and that isn't one of the networking
trees. :-)

Anyways, for the record I'm fine with this change:

Acked-by: David S. Miller <davem@davemloft.net>
