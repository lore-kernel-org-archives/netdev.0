From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter6: ICMPv6 type 143 doesn't match
Date: Fri, 06 May 2005 16:39:51 +0200
Message-ID: <427B81B7.2010808@trash.net>
References: <E1DU2mw-0000UK-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, dlstevens@us.ibm.com, laforge@gnumonks.org,
        netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
        pb@bieringer.de, usagi-users@linux-ipv6.org,
        yasuyuki.kozakai@toshiba.co.jp, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DU2mw-0000UK-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Patrick McHardy <kaber@trash.net> wrote:
>>+               err = dev->hard_header(skb, dev, ETH_P_IPV6, ha, NULL, skb->len);
>>+               if (err < 0) {
>>+                       IP6_INC_STATS(IPSTATS_MIB_OUTDISCARDS);
> 
> You're now incrementing this twice since the callers will also
> increment this.

Thanks, I've removed the line again.

Regards
Patrick
