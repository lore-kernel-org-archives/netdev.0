From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v2 1/2] NET: Clone the sk_buff 'iif' field in
 __skb_clone()
Date: Mon, 07 Jan 2008 22:01:47 -0800 (PST)
Message-ID: <20080107.220147.133397781.davem@davemloft.net>
References: <20080107173829.13488.47471.stgit@flek.americas.hpqcorp.net>
	<20080107174741.13488.93482.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35684
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750716AbYAHGBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 01:01:48 -0500
In-Reply-To: <20080107174741.13488.93482.stgit@flek.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Mon, 07 Jan 2008 12:47:42 -0500

> Both NetLabel and SELinux (other LSMs may grow to use it as well) rely on the
> 'iif' field to determine the receiving network interface of inbound packets.
> Unfortunately, at present this field is not preserved across a skb clone
> operation which can lead to garbage values if the cloned skb is sent back
> through the network stack.  This patch corrects this problem by properly
> copying the 'iif' field in __skb_clone() and removing the 'iif' field
> assignment from skb_act_clone() since it is no longer needed.
> 
> Also, while we are here, put the assignments in the same order as the offsets
> to reduce cacheline bounces.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Applied to net-2.6 and I think I'll toss this into -stable as well.

Thanks.
