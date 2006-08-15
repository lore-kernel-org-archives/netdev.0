From: David Miller <davem@davemloft.net>
Subject: Re: [patch 10/13] fix potential stack overflow in net/core/utils.c
Date: Tue, 15 Aug 2006 00:10:37 -0700 (PDT)
Message-ID: <20060815.001037.122832864.davem@davemloft.net>
References: <200608150603.k7F63iSf012951@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, suresh.b.siddha@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:24756
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965260AbWHOHKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:10:36 -0400
To: akpm@osdl.org
In-Reply-To: <200608150603.k7F63iSf012951@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Mon, 14 Aug 2006 23:03:44 -0700

> From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
> 
> On High end systems (1024 or so cpus) this can potentially cause stack
> overflow.  Fix the stack usage.
> 
> Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied.  A bug fix, so queued up for 2.6.18
