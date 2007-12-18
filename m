From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] [UDP6]: Counter increment on BH mode
Date: Tue, 18 Dec 2007 20:49:27 +0800
Message-ID: <20071218124927.GA30113@gondor.apana.org.au>
References: <474F8255.5060501@cn.fujitsu.com> <20071130111949.GB28277@gerrit.erg.abdn.ac.uk> <20071201015438.GC26895@gondor.apana.org.au> <4753AE07.1040906@cn.fujitsu.com> <20071203113935.GA25124@gondor.apana.org.au> <20071203114912.GA4425@ms2.inr.ac.ru> <20071203115435.GA4202@gondor.apana.org.au> <20071203131723.GA30312@gondor.apana.org.au> <20071215135851.GA29063@gondor.apana.org.au> <20071218114344.GB817@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1177 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753471AbXLRMtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 07:49:31 -0500
Content-Disposition: inline
In-Reply-To: <20071218114344.GB817@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 18, 2007 at 11:43:44AM +0000, Gerrit Renker wrote:
>
> It looks as if this work is reaching the cause of the problem, which would
> be good since the problem propagates to all users of such counters (UDP,
> UDP-Lite, and similar MIB counters). So thank you for taking this issue up,
> I hope that this will lead to a patch set resolving the counter issues.

Heh the counter issue is what led to this patch.  I think the
UDP counters should be fixed already.  Please have a look at
net-2.6.25 and let us know if it's still broken.

As to the SNMP counter issue in general, Christoph Lameter's
new percpu code will greatly simplify this and we won't need
to disable preemption or do the fancy softirq/user splitting
that we have right now.  I eagerly await its acceptance into
the Linux kernel.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
