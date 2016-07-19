From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: fix crash in XFRM_MSG_GETSA netlink handler
Date: Tue, 19 Jul 2016 09:35:06 +0200
Message-ID: <20160719073506.GQ12335@gauss.secunet.com>
References: <1467706688-3631-1-git-send-email-vegard.nossum@oracle.com>
 <20160705.121303.399318377900246102.davem@davemloft.net>
 <20160706022729.GA12971@gondor.apana.org.au>
 <20160710122113.GA24022@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <vegard.nossum@oracle.com>,
	<nicolas.dichtel@6wind.com>, <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:59047 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752463AbcGSHfL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2016 03:35:11 -0400
Content-Disposition: inline
In-Reply-To: <20160710122113.GA24022@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 10, 2016 at 02:21:13PM +0200, Steffen Klassert wrote:
> On Wed, Jul 06, 2016 at 10:27:29AM +0800, Herbert Xu wrote:
> > On Tue, Jul 05, 2016 at 12:13:03PM -0700, David Miller wrote:
> > > From: Vegard Nossum <vegard.nossum@oracle.com>
> > > Date: Tue,  5 Jul 2016 10:18:08 +0200
> > > 
> > > > If we hit any of the error conditions inside xfrm_dump_sa(), then
> > > > xfrm_state_walk_init() never gets called. However, we still call
> > > > xfrm_state_walk_done() from xfrm_dump_sa_done(), which will crash
> > > > because the state walk was never initialized properly.
> > > > 
> > > > We can fix this by setting cb->args[0] only after we've processed the
> > > > first element and checking this before calling xfrm_state_walk_done().
> > > > 
> > > > Fixes: d3623099d3 ("ipsec: add support of limited SA dump")
> > > > Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> > > > Cc: Steffen Klassert <steffen.klassert@secunet.com>
> > > > Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
> > > 
> > > I assume Steffen will pick this up.
> > 
> > I think Steffen said that he is going to be on vacation for two
> > weeks starting this week.
> 
> Right, I'll take care of it as soon as I'm back.

Now applied to the ipsec tree, thanks a lot!
