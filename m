From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e100: Fix the TX workqueue race
Date: Fri, 23 Apr 2010 16:35:45 -0700 (PDT)
Message-ID: <20100423.163545.157549100.davem@davemloft.net>
References: <20100423143356.7092.45260.stgit@localhost.localdomain>
	<20100423.163127.62645049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: alan@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55522
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750910Ab0DWXfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 19:35:40 -0400
In-Reply-To: <20100423.163127.62645049.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 23 Apr 2010 16:31:27 -0700 (PDT)

> I'll apply this to net-2.6, thanks Alan.

Nevermind...

Doesn't apply to net-2.6, but even when I fix that up it doesn't
even compile.  There is no 'dev' variable present etc.

You even use a combination of "dev" and "netdev" in the resulting
code block.

If it doesn't even build, I doubt it's been tested either.

Please resolve this and get some testing on it, thanks.
