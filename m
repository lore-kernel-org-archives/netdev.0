From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netfilter: xt_socket: add XT_SOCKET_NOWILDCARD
 flag
Date: Thu, 20 Jun 2013 11:55:00 +0200
Message-ID: <20130620095500.GB698@localhost>
References: <1370300249.24311.190.camel@edumazet-glaptop>
 <1371717515.3252.392.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1371717515.3252.392.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 20, 2013 at 01:38:35AM -0700, Eric Dumazet wrote:
> On Mon, 2013-06-03 at 15:57 -0700, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > xt_socket module can be a nice replacement to conntrack module
> > in some cases (SYN filtering for example)
> > 
> > But it lacks the ability to match the 3rd packet of TCP
> > handshake (ACK coming from the client).
> > 
> > Add a XT_SOCKET_NOWILDCARD flag to disable the wildcard mechanism
> > 
> > iptables -I INPUT -p tcp --syn -j SYN_CHAIN
> > iptables -I INPUT -m socket -j ACCEPT
> > 
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Patrick McHardy <kaber@trash.net>
> > Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> > ---
> 
> Hi Pablo, is there any problem with this patch ?

user-space part is missing (or at least I didn't manage to find the
patch).

We've been adding new revision for such a changes. I know it's a bit
too much, but we want to make sure that a user does not set this
option from user-space and it's silently ignored by iptables.
