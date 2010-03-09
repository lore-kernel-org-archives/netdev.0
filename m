From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Tue, 9 Mar 2010 22:12:59 +0100
Message-ID: <201003092212.59627.arnd@arndb.de>
References: <20100228054012.GA7583@gondor.apana.org.au> <20100307024500.GA20126@gondor.apana.org.au> <20100307031151.GA7546@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:53880 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326Ab0CIVNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 16:13:18 -0500
In-Reply-To: <20100307031151.GA7546@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 07 March 2010, Paul E. McKenney wrote:
> On Sun, Mar 07, 2010 at 10:45:00AM +0800, Herbert Xu wrote:
> > On Sat, Mar 06, 2010 at 11:00:00AM -0800, Paul E. McKenney wrote:
> 
> Arnd, would it be reasonable to extend your RCU-sparse changes to have
> four different pointer namespaces, one for each flavor of RCU?  (RCU,
> RCU-bh, RCU-sched, and SRCU)?  Always a fan of making the computer do
> the auditing where reasonable.  ;-)
> 
> This could potentially catch the mismatched call_rcu()s, at least if the
> rcu_head could be labeled.
> 
> Other thoughts?

I've just tried annotating net/ipv4/route.c like this and did not get
very far, because the same pointers are used for rcu and rcu_bh.
Could you check if this is a false positive or an actual finding?

	Arnd
