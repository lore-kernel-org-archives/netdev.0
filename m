From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH]  introduce eth_hdr(skb)
Date: Sat, 2 Oct 2004 11:01:34 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.10.10410021058520.7525-100000@netwinder.perches.com>
References: <415EDD0C.9080507@conectiva.com.br>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <415EDD0C.9080507@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



-       } else if (skb->mac.ethernet->h_proto == __constant_htons(ETH_P_ARP)) {
+       } else if (eth_hdr(skb)->h_proto == htons(ETH_P_ARP)) {

I believe the __constant_htons conversions to htons are incorrect.
