From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] SFQ: use net_random
Date: Sun, 20 Jan 2008 17:19:55 -0800 (PST)
Message-ID: <20080120.171955.95263904.davem@davemloft.net>
References: <20080118144309.3530ed2f@deepthought>
	<20080118144730.7878f12a@deepthought>
	<20080119041820.GA24840@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47512
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756435AbYAUBTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 20:19:50 -0500
In-Reply-To: <20080119041820.GA24840@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Fri, 18 Jan 2008 20:18:20 -0800

> On Fri, Jan 18, 2008 at 02:47:30PM -0800, Stephen Hemminger wrote:
> > SFQ doesn't need true random numbers, it is only using them to salt
> > a hash. Therefore it is better to use net_random() and avoid any possible
> > problems with depleting the entropy pool.
> 
> The random-number algorithm used by net_random() certainly does appear
> to be considerably stronger than the one I used to generate the results
> in the 1990 paper.  ;-)
> 
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Also applied, thanks.
