From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_trie: fix warning from rcu_assign_poinger
Date: Sat, 22 Mar 2008 18:02:23 -0700 (PDT)
Message-ID: <20080322.180223.90499780.davem@davemloft.net>
References: <20080317140236.6160fb4f@extreme>
	<20080317142706.235594c9@extreme>
	<20080318140654.GA8222@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48724
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755355AbYCWBCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 21:02:07 -0400
In-Reply-To: <20080318140654.GA8222@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Tue, 18 Mar 2008 07:06:54 -0700

> On Mon, Mar 17, 2008 at 02:27:06PM -0700, Stephen Hemminger wrote:
> > This gets rid of a warning caused by the test in rcu_assign_pointer.
> > I tried to fix rcu_assign_pointer, but that devolved into a long
> > set of discussions about doing it right that came to no real solution.
> > Since the test in rcu_assign_pointer for constant NULL would never succeed in
> > fib_trie, just open code instead.
> 
> Indeed -- fooling gcc is nontrivial.  :-/
> 
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Applied, thanks everyone.
