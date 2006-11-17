From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 1/10] cxgb3 - main header files
Date: Fri, 17 Nov 2006 13:48:14 -0800
Message-ID: <adaejs1lp7l.fsf@cisco.com>
References: <20061117202320.25878.26769.stgit@colfax2.asicdesigners.com>
	<20061117124902.7e69af2e@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Divy Le Ray <divy@chelsio.com>" <divy@chelsio.com>,
	jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:62276 "EHLO
	sj-iport-5.cisco.com") by vger.kernel.org with ESMTP
	id S1755953AbWKQVsY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 16:48:24 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061117124902.7e69af2e@freekitty> (Stephen Hemminger's message of "Fri, 17 Nov 2006 12:49:02 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > +#define MDIO_LOCK(adapter) down(&(adapter)->mdio_lock)
 > > +#define MDIO_UNLOCK(adapter) up(&(adapter)->mdio_lock)
 > 
 > Please don't wrap locks

Plus these should probably be mutexes, not semaphores.

 > > +int t3_offload_tx(struct t3cdev *tdev, struct sk_buff *skb);
 > 
 > What kind of offload?  You remember TOE was rejected.

But we're OK with RDMA over TCP (iWARP) I think...

 - R.
