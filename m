From: David Miller <davem@davemloft.net>
Subject: Re: [PKT_SCHED] ematch: tcf_em_destroy robustness
Date: Sat, 09 Feb 2008 23:27:02 -0800 (PST)
Message-ID: <20080209.232702.197214366.davem@davemloft.net>
References: <20080208104832.690e140e@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33586
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758745AbYBJH0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 02:26:30 -0500
In-Reply-To: <20080208104832.690e140e@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 8 Feb 2008 10:48:32 -0800

> Make the code in tcf_em_tree_destroy more robust and cleaner:
>  * Don't need to cast pointer to kfree() or avoid passing NULL.
>  * After freeing the tree, clear the pointer to avoid possible problems
> from repeated free.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
