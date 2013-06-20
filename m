From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: xt_socket: add XT_SOCKET_NOWILDCARD
 flag
Date: Thu, 20 Jun 2013 01:38:35 -0700
Message-ID: <1371717515.3252.392.camel@edumazet-glaptop>
References: <1370300249.24311.190.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1370300249.24311.190.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-06-03 at 15:57 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> xt_socket module can be a nice replacement to conntrack module
> in some cases (SYN filtering for example)
> 
> But it lacks the ability to match the 3rd packet of TCP
> handshake (ACK coming from the client).
> 
> Add a XT_SOCKET_NOWILDCARD flag to disable the wildcard mechanism
> 
> iptables -I INPUT -p tcp --syn -j SYN_CHAIN
> iptables -I INPUT -m socket -j ACCEPT
> 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> ---

Hi Pablo, is there any problem with this patch ?

Thanks


