From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH]  introduce eth_hdr(skb)
Date: Sat, 02 Oct 2004 14:22:41 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415EE3E1.7020806@conectiva.com.br>
References: <Pine.LNX.4.10.10410021058520.7525-100000@netwinder.perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Joe Perches <joe@perches.com>
In-Reply-To: <Pine.LNX.4.10.10410021058520.7525-100000@netwinder.perches.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Joe Perches wrote:
> 
> -       } else if (skb->mac.ethernet->h_proto == __constant_htons(ETH_P_ARP)) {
> +       } else if (eth_hdr(skb)->h_proto == htons(ETH_P_ARP)) {
> 
> I believe the __constant_htons conversions to htons are incorrect.

No they aren't, look at the generated code for both variations when 
receiving a constant :-)

- Arnaldo
