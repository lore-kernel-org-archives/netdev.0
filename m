From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] remove rcu_assign_pointer(NULL) penalty with
 type/macro safety
Date: Wed, 13 Feb 2008 16:09:00 -0800
Message-ID: <20080213160900.1a84dfe9.akpm@linux-foundation.org>
References: <20080213144233.05e860cb@extreme>
	<20080213233744.GO12393@linux.vnet.ibm.com>
	<20080213155245.455944f8.akpm@linux-foundation.org>
	<20080213.155738.71849437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com,
	"stephen.hemminger@vyatta.com"@mail.vyatta.com,
	linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	netdev@vger.kernel.org, dipankar@in.ibm.com, ego@in.ibm.com,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57462 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759153AbYBNAKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 19:10:39 -0500
In-Reply-To: <20080213.155738.71849437.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Feb 2008 15:57:38 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 13 Feb 2008 15:52:45 -0800
> 
> > On Wed, 13 Feb 2008 15:37:44 -0800
> > "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> > 
> > > Ah.  It does take a bit to get fib_trie into one's build -- allyesconfig
> > > doesn't cut it.
> > 
> > This is not good.  The sole purpose of allmodconfig and allyesconfig is for
> > compilation and linkage coverage testing.  Hence we should aim to get as
> > much code as possible included in those cases.
> 
> Well, in this case there is a choice, either you use one routing
> lookup datastructure or the other.  It's not purposefully being hidden
> from the everything builds :-)

oic.  yes, that is a bit of a problem.  Oh well.

`make randconfig' seems to be able to enable CONFIG_IP_FIB_TRIE about one
time in eight ;)

