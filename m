From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 17:33:42 +0400
Message-ID: <20070927133342.GA3184@2ka.mipt.ru>
References: <20070927092512.GD29329@2ka.mipt.ru> <20070927093358.GA15357@gondor.apana.org.au> <20070927100753.GA22323@2ka.mipt.ru> <20070927102916.GA15749@gondor.apana.org.au> <20070927124120.GA8897@2ka.mipt.ru> <20070927124515.GA16706@gondor.apana.org.au> <20070927131008.GA15997@2ka.mipt.ru> <46FBAD40.8040806@trash.net> <20070927132507.GA25353@2ka.mipt.ru> <46FBB064.6070508@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	jamal <hadi@cyberus.ca>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51138 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751904AbXI0NeS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 09:34:18 -0400
Content-Disposition: inline
In-Reply-To: <46FBB064.6070508@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 27, 2007 at 03:30:12PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> Evgeniy Polyakov wrote:
> > On Thu, Sep 27, 2007 at 03:16:48PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> > 
> >>
> >>These are way too large to get inlined, please move somewhere below
> >>net/core.
> > 
> > 
> > I knew that... :)
> > I'm pretty sure new files called net/core/helpers.c which will host that
> > helper is not a good solution too?
> 
> 
> I like Herbert's suggestion of net/core/utils.c better (and without the
> nf_ prefix please).

I've put it there without nf_ prefix and updated netfilter header to
create new inlune function with that prefix for private netfilter usage.

-- 
	Evgeniy Polyakov
