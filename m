From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [1/2] [NET] link_watch: Move link watch list into net_device
Date: Thu, 10 May 2007 15:22:17 -0700
Message-ID: <46439B19.7010706@goop.org>
References: <20070504232051.411946839@goop.org>	<20070504232121.492190579@goop.org>	<20070505091624.GA8890@infradead.org>	<463C56D3.8060609@goop.org>	<20070505102305.GA12771@gondor.apana.org.au>	<463F95C3.60407@goop.org>	<20070508121322.GA21647@gondor.apana.org.au>	<464395E5.2090500@goop.org> <20070510151426.d808384f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@infradead.org>, Andi Kleen <ak@suse.de>,
	virtualization@lists.osdl.org, lkml <linux-kernel@vger.kernel.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>, Valdis.Kletnieks@vt.edu
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:35548 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755110AbXEJWWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 18:22:21 -0400
In-Reply-To: <20070510151426.d808384f.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Five minutes after boot is when jiffies wraps.  Are you sure it's
> a list-screwup rather than a jiffy-wrap screwup?
>   


Hm, its suggestive, isn't it?  Apparently they've already fixed this in
the sekret networking clubhouse, so I'll need to track it down.

    J
