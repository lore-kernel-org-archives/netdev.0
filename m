From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: take care of timewait sockets
Date: Wed, 05 Sep 2012 19:52:22 +0200
Message-ID: <1346867542.13121.160.camel@edumazet-glaptop>
References: <1346780943.13121.58.camel@edumazet-glaptop>
	 <20120905171016.GA23211@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45249 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164Ab2IERw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 13:52:27 -0400
In-Reply-To: <20120905171016.GA23211@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-05 at 19:10 +0200, Pablo Neira Ayuso wrote:
> On Tue, Sep 04, 2012 at 07:49:03PM +0200, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Sami Farin reported crashes in xt_LOG because it assumes skb->sk is a
> > full blown socket.
> > 
> > But with TCP early demux, we can have skb->sk pointing to a timewait
> > socket.
> 
> TCP early demux is there since 3.6-rc.
> 
> I'll add that to the changelog if you don't mind, to help tracking
> things for -stable.

Sure, its not a stable candidate.
