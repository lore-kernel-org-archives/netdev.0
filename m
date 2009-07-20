From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 13467] New: Cannot set larger mtu on vlan
 then on underlying untagged device
Date: Mon, 20 Jul 2009 07:36:01 -0700 (PDT)
Message-ID: <20090720.073601.197255459.davem@davemloft.net>
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
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59760
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751625AbZGTOf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 10:35:56 -0400
In-Reply-To: <20090706101950.GA18953@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 6 Jul 2009 18:19:50 +0800

> vlan: Propagate physical MTU changes
> 
> When the physical MTU changes we want to ensure that all existing
> VLAN device MTUs do not exceed the new underlying MTU.  This patch
> adds that propagation.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next-2.6, thanks.
