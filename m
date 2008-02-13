From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] remove rcu_assign_pointer(NULL) penalty with
 type/macro safety
Date: Wed, 13 Feb 2008 15:55:36 -0800
Message-ID: <20080213155536.5541f798@extreme>
References: <20080213220024.GA30729@linux.vnet.ibm.com>
	<20080213143537.1b806790@extreme>
	<20080213224134.GK12393@linux.vnet.ibm.com>
	<20080213144233.05e860cb@extreme>
	<20080213233744.GO12393@linux.vnet.ibm.com>
	<20080213155245.455944f8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com,
	"stephen.hemminger@vyatta.com"@mail.vyatta.com,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, dipankar@in.ibm.com, ego@in.ibm.com,
	herbert@gondor.apana.org.au
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:37931 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756291AbYBMXzk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 18:55:40 -0500
In-Reply-To: <20080213155245.455944f8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Feb 2008 15:52:45 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 13 Feb 2008 15:37:44 -0800
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> 
> > Ah.  It does take a bit to get fib_trie into one's build -- allyesconfig
> > doesn't cut it.
> 
> This is not good.  The sole purpose of allmodconfig and allyesconfig is for
> compilation and linkage coverage testing.  Hence we should aim to get as
> much code as possible included in those cases.
> 

The current model is compile time choice. It is on my long term list
to make this a runtime option.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
