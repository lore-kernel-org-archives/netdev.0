From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 13467] New: Cannot set larger mtu on vlan
 then on underlying untagged device
Date: Thu, 16 Jul 2009 19:30:17 -0700 (PDT)
Message-ID: <20090716.193017.145913611.davem@davemloft.net>
References: <20090609143438.87e6bf5d.akpm@linux-foundation.org>
	<20090706101950.GA18953@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, tomek@jot23.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59510
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933969AbZGQCaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 22:30:12 -0400
In-Reply-To: <20090706101950.GA18953@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 6 Jul 2009 18:19:50 +0800

> Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>>>            Summary: Cannot set larger mtu on vlan then on underlying
>>>                     untagged device
> 
> Please try this patch.
> 
> vlan: Propagate physical MTU changes
> 
> When the physical MTU changes we want to ensure that all existing
> VLAN device MTUs do not exceed the new underlying MTU.  This patch
> adds that propagation.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Please can we have some test results for this patch?  It's been
more than a week since this patch and request for testing was
posted.

Thanks.
