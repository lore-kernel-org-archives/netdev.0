From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] RDS rds_iovec fixes
Date: Sat, 30 Oct 2010 16:34:37 -0700 (PDT)
Message-ID: <20101030.163437.246540203.davem@davemloft.net>
References: <1288316459-4679-1-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com
To: andy.grover@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59491
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754095Ab0J3XeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Oct 2010 19:34:13 -0400
In-Reply-To: <1288316459-4679-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Grover <andy.grover@oracle.com>
Date: Thu, 28 Oct 2010 18:40:54 -0700

> This patchset includes Linus' rds_iovec overflow fix, as well as making
> a copy of the rds_iovec array to prevent userspace from changing them after
> we've checked them.
> 
> Please especially review patch 5. We go from 3 to 2 iovec copies, but it's not
> trivial to go to one, due to some code that wants to preallocate space for SGs.
> Until that code can be changed, patch 5 attempts to safely handle the scenario.

I looked carefully over these and they look ok.

Applied, thanks Andy.
