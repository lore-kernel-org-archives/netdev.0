From: David Miller <davem@davemloft.net>
Subject: Re: git-net, git-netdev-all and everything else on g5
Date: Thu, 28 Jun 2007 13:45:03 -0700 (PDT)
Message-ID: <20070628.134503.132927540.davem@davemloft.net>
References: <20070628021338.0d37f95a.akpm@linux-foundation.org>
	<20070628191831.GA25497@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40043
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757619AbXF1Uoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 16:44:44 -0400
In-Reply-To: <20070628191831.GA25497@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 29 Jun 2007 03:18:31 +0800

> On Thu, Jun 28, 2007 at 09:13:38AM +0000, Andrew Morton wrote:
> > 
> > With the full -mm lineup, my tg3-using powerpc g5 spits lots of these:
> > 
> > windfarm: Drive bay control loop started.
> > audit(1183017094.732:2): audit_pid=2117 old=0 by auid=4294967295
> > ------------[ cut here ]------------
> > Badness at net/core/dev.c:1303
> 
> Hmm, we really should come up with a better way for checking
> checksum support.
> 
> [NET]: Fix TX checksum feature check
> 
> This patch fixes a boolean error in the new TX checksum check
> that causes bogus TSO packets to be generated.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Wasn't I just mentioning how much of a mess these tests
are the other day? :-)

Patch applied, thanks Herbert!
