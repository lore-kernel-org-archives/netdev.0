From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH]  introduce eth_hdr(skb)
Date: Sat, 02 Oct 2004 15:10:26 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415EEF12.2050105@conectiva.com.br>
References: <Pine.LNX.4.10.10410021136110.7525-100000@netwinder.perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Joe Perches <joe@perches.com>
In-Reply-To: <Pine.LNX.4.10.10410021136110.7525-100000@netwinder.perches.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Joe Perches wrote:
> 
> On Sat, 2 Oct 2004, Arnaldo Carvalho de Melo wrote:
> 
>>Joe Perches wrote:
>>
>>>-       } else if (skb->mac.ethernet->h_proto == __constant_htons(ETH_P_ARP)) {
>>>+       } else if (eth_hdr(skb)->h_proto == htons(ETH_P_ARP)) {
>>>
>>>I believe the __constant_htons conversions to htons are incorrect.
>>
>>No they aren't, look at the generated code for both variations when 
>>receiving a constant :-)
> 
> 
> Perhaps, but if you are going to change some, shouldn't you instead
> change all the similar net/bridge uses in a different changset?

I'm touching just the ones that are in lines changed by this changeset,
a later patch can finish this.

- Arnaldo
