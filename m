From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NetLabel: correct usage of RCU locking
Date: Fri, 26 Oct 2007 04:29:20 -0700 (PDT)
Message-ID: <20071026.042920.66472865.davem@davemloft.net>
References: <20071025134727.6382.79273.stgit@flek.americas.hpqcorp.net>
	<20071025135238.6382.62146.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58743
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750737AbXJZL3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 07:29:19 -0400
In-Reply-To: <20071025135238.6382.62146.stgit@flek.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>
Date: Thu, 25 Oct 2007 09:52:38 -0400

> This fixes some awkward, and perhaps even problematic, RCU lock usage in the
> NetLabel code as well as some other related trivial cleanups found when
> looking through the RCU locking.  Most of the changes involve removing the
> redundant RCU read locks wrapping spinlocks in the case of a RCU writer.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Applied, thanks Paul!
