From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: take care of timewait sockets
Date: Wed, 5 Sep 2012 19:10:16 +0200
Message-ID: <20120905171016.GA23211@1984>
References: <1346780943.13121.58.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1346780943.13121.58.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 04, 2012 at 07:49:03PM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Sami Farin reported crashes in xt_LOG because it assumes skb->sk is a
> full blown socket.
> 
> But with TCP early demux, we can have skb->sk pointing to a timewait
> socket.

TCP early demux is there since 3.6-rc.

I'll add that to the changelog if you don't mind, to help tracking
things for -stable.
