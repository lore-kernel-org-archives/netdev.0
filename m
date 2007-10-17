From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net: Fix new EMAC driver for NAPI changes
Date: Wed, 17 Oct 2007 11:46:54 +1000
Message-ID: <1192585614.11899.108.camel@pasglop>
References: <1192513250.19073.10.camel@pasglop>
	 <47156258.5010800@garzik.org>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux.foundation.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40998 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756350AbXJQBrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 21:47:14 -0400
In-Reply-To: <47156258.5010800@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2007-10-16 at 21:16 -0400, Jeff Garzik wrote:
> Benjamin Herrenschmidt wrote:
> > net: Fix new EMAC driver for NAPI changes
> > 
> > This fixes the new EMAC driver for the NAPI updates. The previous patch
> > by Roland Dreier (already applied) to do that doesn't actually work. This
> > applies on top of it makes it work on my test Ebony machine.
> > 
> > This patch depends on "net: Add __napi_sycnhronize() to sync with napi poll"
> > posted previously.
> > 
> > Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > ---
> > 
> > The old EMAC driver does things a bit differently (doesn't do useful
> > locking :-) and seems to work with Roland patch. So I'm not going to
> > touch it unless somebody reports me that it has problems
> 
> applied

Beware that the depend patch for __napi_synchronize() is still being
discussed :-)

Cheers,
Ben.


