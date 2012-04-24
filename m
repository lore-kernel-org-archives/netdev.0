From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive for
 TCP
Date: Tue, 24 Apr 2012 10:25:39 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1204241022290.26005@router.home>
References: <1335173934.3293.84.camel@edumazet-glaptop> <4F958DFD.7010207@hp.com> <1335201795.5205.35.camel@edumazet-glaptop> <20120423.160149.1515408777176168288.davem@davemloft.net> <1335213446.5205.65.camel@edumazet-glaptop>  <4F95C22D.3010908@hp.com>
 <1335216631.5205.71.camel@edumazet-glaptop>  <4F95CECF.6030901@hp.com> <1335218707.5205.87.camel@edumazet-glaptop> <4F95D4CA.7020005@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, ncardwell@google.com, maze@google.com,
	ycheng@google.com, ilpo.jarvinen@helsinki.fi
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp103.prem.mail.ac4.yahoo.com ([76.13.13.42]:45695 "HELO
	smtp103.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755299Ab2DXPZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 11:25:43 -0400
In-Reply-To: <4F95D4CA.7020005@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Apr 2012, Rick Jones wrote:

> Is it at all possible to have the copies happen without the connection being
> locked?  If indeed it is possible to be held-off with the connection locked
> for the better part of 3/4 of a millisecond, just what will that do to 40 or
> 100 GbE?  If you've been seeing queues of 300 ACKs at 10 GbE that would be
> 3000 at 100 GbE, and assuming those are all in a 2048 byte buffer thats 6MB
> just of ACKs.  I suppose 100GbE does mean non-trivial quantities of buffering
> anyway but that does still seem rather high.

At some point people will need to realize that it is not business as usual
if one tries to use the current network porotocols at speeds above 1G.

There is a reason for high speed networks implementing new protocols like
RDMA techniques and lossless characteristics of a network.
