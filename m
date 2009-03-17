From: David Miller <davem@davemloft.net>
Subject: Re: Kernel panic during stress with igb in the upstream kernel
Date: Tue, 17 Mar 2009 13:11:05 -0700 (PDT)
Message-ID: <20090317.131105.111221133.davem@davemloft.net>
References: <20090316132240.GA18413@gondor.apana.org.au>
	<20090317093724.GA5743@ff.dom.local>
	<20090317100203.GA23396@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, emil.s.tantilov@intel.com,
	alexander.h.duyck@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33662
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752746AbZCQULT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 16:11:19 -0400
In-Reply-To: <20090317100203.GA23396@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 17 Mar 2009 18:02:03 +0800

> On Tue, Mar 17, 2009 at 09:37:24AM +0000, Jarek Poplawski wrote:
> >
> > Probably I miss something, but you seem to assume here this skb will
> > be taken by netpoll later. But if it's not active (trapped) vlan
> > packet will be passed as "normal"?
> 
> Good point.  I'll see if this stuff can be simplified further,
> but for now, let's go for the obvious fix.
> 
> gro: Fix vlan/netpoll check again
> 
> Jarek Poplawski pointed out that my previous fix is broken for
> VLAN+netpoll as if netpoll is enabled we'd end up in the normal
> receive path instead of the VLAN receive path.
> 
> This patch fixes it by calling the VLAN receive hook.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
