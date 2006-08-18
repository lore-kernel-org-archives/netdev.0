From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 6936] BUG: warning at
 net/core/dev.c:1171/skb_checksum_help()
Date: Thu, 17 Aug 2006 18:22:50 -0700 (PDT)
Message-ID: <20060817.182250.115908321.davem@davemloft.net>
References: <200608151829.k7FITxKM006438@fire-2.osdl.org>
	<20060816012900.GA23430@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, shemminger@osdl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8648
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932314AbWHRBWm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 21:22:42 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060816012900.GA23430@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 16 Aug 2006 11:29:00 +1000

> On Tue, Aug 15, 2006 at 11:29:59AM -0700, bugme-daemon@bugzilla.kernel.org wrote:
> > http://bugzilla.kernel.org/show_bug.cgi?id=6936
> 
> It's actually a bug in the bridging code :)
> 
> [BRIDGE]: Disable SG/GSO if TX checksum is off

Applied, thanks a lot Herbert.
