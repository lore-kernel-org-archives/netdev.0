From: David Miller <davem@davemloft.net>
Subject: Re: git-net locking bustage
Date: Fri, 04 May 2007 12:15:28 -0700 (PDT)
Message-ID: <20070504.121528.75430364.davem@davemloft.net>
References: <20070504115316.998c7fd3.akpm@linux-foundation.org>
	<463B8360.10805@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35594
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161901AbXEDTPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 15:15:42 -0400
In-Reply-To: <463B8360.10805@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 04 May 2007 21:02:56 +0200

> [NETLINK]: Remove bogus BUG_ON
> 
> Remove bogus BUG_ON(mutex_is_locked(nlk_sk(sk)->cb_mutex)), when the
> netlink_kernel_create caller specifies an external mutex it might
> validly be locked.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
