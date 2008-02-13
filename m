From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] remove rcu_assign_pointer(NULL) penalty with
 type/macro safety
Date: Wed, 13 Feb 2008 15:57:38 -0800 (PST)
Message-ID: <20080213.155738.71849437.davem@davemloft.net>
References: <20080213144233.05e860cb@extreme>
	<20080213233744.GO12393@linux.vnet.ibm.com>
	<20080213155245.455944f8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com,
	"stephen.hemminger@vyatta.com"@mail.vyatta.com,
	linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	netdev@vger.kernel.org, dipankar@in.ibm.com, ego@in.ibm.com,
	herbert@gondor.apana.org.au
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58237
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760704AbYBMX5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 18:57:09 -0500
In-Reply-To: <20080213155245.455944f8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 13 Feb 2008 15:52:45 -0800

> On Wed, 13 Feb 2008 15:37:44 -0800
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> 
> > Ah.  It does take a bit to get fib_trie into one's build -- allyesconfig
> > doesn't cut it.
> 
> This is not good.  The sole purpose of allmodconfig and allyesconfig is for
> compilation and linkage coverage testing.  Hence we should aim to get as
> much code as possible included in those cases.

Well, in this case there is a choice, either you use one routing
lookup datastructure or the other.  It's not purposefully being hidden
from the everything builds :-)
