From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: add rcu_read_lock
Date: Wed, 28 Jul 2010 11:01:58 -0700
Message-ID: <20100728110158.2d77123a@nehalam>
References: <20100727134223.5bb0be30@nehalam>
	<1280302431.3684.0.camel@jlt3.sipsolutions.net>
	<20100728095730.11450561@nehalam>
	<20100728.105209.25114107.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43204 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751598Ab0G1SCB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jul 2010 14:02:01 -0400
In-Reply-To: <20100728.105209.25114107.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jul 2010 10:52:09 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 28 Jul 2010 09:57:30 -0700
> 
> > Long ago, when bridge was converted to RCU, rcu lock was equivalent
> > to having preempt disabled. RCU has changed a lot since then and
> > bridge code was still assuming the since transmit was called with
> > bottom half disabled, it was RCU safe.
> > 
> > In addition to fixing the code, update the comments about
> > locking to match current state as well.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> As I stated in another email I added the original commit.
> 
> This version still didn't apply to net-2.6 and also you failed
> to add a tested-by tag for Johannes to the commit message, which
> I also did alongside backporting the original patch to net-2.6

I didn't see yours, if you look at the date it was ships in the night.


-- 
