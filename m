From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 nf-next] netfilter: xt_socket: add
 XT_SOCKET_NOWILDCARD flag
Date: Tue, 25 Jun 2013 02:57:43 +0200
Message-ID: <20130625005743.GA3437@localhost>
References: <1370300249.24311.190.camel@edumazet-glaptop>
 <1371732742.3252.408.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1371732742.3252.408.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 20, 2013 at 05:52:22AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> xt_socket module can be a nice replacement to conntrack module
> in some cases (SYN filtering for example)
> 
> But it lacks the ability to match the 3rd packet of TCP
> handshake (ACK coming from the client).
> 
> Add a XT_SOCKET_NOWILDCARD flag to disable the wildcard mechanism.
> 
> The wildcard is the legacy socket match behavior, that ignores
> LISTEN sockets bound to INADDR_ANY (or ipv6 equivalent)
> 
> iptables -I INPUT -p tcp --syn -j SYN_CHAIN
> iptables -I INPUT -m socket --nowildcard -j ACCEPT

Applied, thanks Eric!
