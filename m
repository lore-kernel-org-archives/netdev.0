From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] dst_entry structure use,lastuse and refcnt abstraction
Date: Thu, 23 Jun 2005 20:47:02 -0700 (PDT)
Message-ID: <20050623.204702.26274560.davem@davemloft.net>
References: <Pine.LNX.4.62.0506231953260.28244@graphe.net>
	<20050623.203647.88475017.davem@davemloft.net>
	<Pine.LNX.4.62.0506232037430.28814@graphe.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	shai@scalex86.org, akpm@osdl.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <linux-net-owner@vger.kernel.org>
To: christoph@lameter.com
In-Reply-To: <Pine.LNX.4.62.0506232037430.28814@graphe.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Lameter <christoph@lameter.com>
Date: Thu, 23 Jun 2005 20:40:25 -0700 (PDT)

> Nothing as far as I can tell. The main benefit may be reorganization of 
> the code.

You told us way back in the original thread that the final atomic dec
shows up very much on NUMA, and if it could be avoided (and changed
into a read test), it would help a lot on NUMA.

> > 	NETWORKING [GENERAL]
> > 	P:	Networking Team
> > 	M:	netdev@vger.kernel.org
> > 	L:	netdev@vger.kernel.org
> > 	S:	Maintained
> > 
> > Thanks.
> 
> Yes and it was recently changed. Typical use is linux-xxx@vger.kernel.org

netdev@oss.sgi.com is what used to be the place for networking
stuff, it's not netdev@vger.kernel.org

