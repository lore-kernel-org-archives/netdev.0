From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH]  introduce eth_hdr(skb)
Date: Sat, 2 Oct 2004 11:40:19 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.10.10410021136110.7525-100000@netwinder.perches.com>
References: <415EE3E1.7020806@conectiva.com.br>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <415EE3E1.7020806@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 2 Oct 2004, Arnaldo Carvalho de Melo wrote:
> Joe Perches wrote:
> > 
> > -       } else if (skb->mac.ethernet->h_proto == __constant_htons(ETH_P_ARP)) {
> > +       } else if (eth_hdr(skb)->h_proto == htons(ETH_P_ARP)) {
> > 
> > I believe the __constant_htons conversions to htons are incorrect.
> 
> No they aren't, look at the generated code for both variations when 
> receiving a constant :-)

Perhaps, but if you are going to change some, shouldn't you instead
change all the similar net/bridge uses in a different changset?
