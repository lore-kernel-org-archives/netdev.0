From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: take care of timewait sockets
Date: Thu, 6 Sep 2012 14:34:07 +0200
Message-ID: <20120906123407.GB1217@1984>
References: <1346780943.13121.58.camel@edumazet-glaptop>
 <20120905171016.GA23211@1984>
 <1346867542.13121.160.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42866 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208Ab2IFMeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2012 08:34:09 -0400
Content-Disposition: inline
In-Reply-To: <1346867542.13121.160.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 05, 2012 at 07:52:22PM +0200, Eric Dumazet wrote:
> On Wed, 2012-09-05 at 19:10 +0200, Pablo Neira Ayuso wrote:
> > On Tue, Sep 04, 2012 at 07:49:03PM +0200, Eric Dumazet wrote:
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > Sami Farin reported crashes in xt_LOG because it assumes skb->sk is a
> > > full blown socket.
> > > 
> > > But with TCP early demux, we can have skb->sk pointing to a timewait
> > > socket.
> > 
> > TCP early demux is there since 3.6-rc.
> > 
> > I'll add that to the changelog if you don't mind, to help tracking
> > things for -stable.
> 
> Sure, its not a stable candidate.

Done, applied thanks a lot Eric!
