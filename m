From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: add rcu_read_lock
Date: Wed, 28 Jul 2010 10:52:09 -0700 (PDT)
Message-ID: <20100728.105209.25114107.davem@davemloft.net>
References: <20100727134223.5bb0be30@nehalam>
	<1280302431.3684.0.camel@jlt3.sipsolutions.net>
	<20100728095730.11450561@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42534
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755084Ab0G1Rvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 13:51:51 -0400
In-Reply-To: <20100728095730.11450561@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 28 Jul 2010 09:57:30 -0700

> Long ago, when bridge was converted to RCU, rcu lock was equivalent
> to having preempt disabled. RCU has changed a lot since then and
> bridge code was still assuming the since transmit was called with
> bottom half disabled, it was RCU safe.
> 
> In addition to fixing the code, update the comments about
> locking to match current state as well.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

As I stated in another email I added the original commit.

This version still didn't apply to net-2.6 and also you failed
to add a tested-by tag for Johannes to the commit message, which
I also did alongside backporting the original patch to net-2.6
