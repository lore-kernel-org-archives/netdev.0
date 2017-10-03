From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] bridge: Fix format string for %ul
Date: Tue, 3 Oct 2017 13:43:11 -0700
Message-ID: <20171003134311.34681644@xeon-e3>
References: <1472267428-810527-1-git-send-email-green@linuxhacker.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Oleg Drokin <green@linuxhacker.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472267428-810527-1-git-send-email-green@linuxhacker.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 26 Aug 2016 23:10:28 -0400
Oleg Drokin <green@linuxhacker.ru> wrote:

> %ul would print an unsigned value and a letter l,
> likely it was %lu that was meant to print the long int,
> but in reality the values printed there are just regular signed
> ints, so just dropping the l altogether.
> 
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> ---
>  net/bridge/br_stp_bpdu.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
> index 5881fbc..15c4a9c 100644
> --- a/net/bridge/br_stp_bpdu.c
> +++ b/net/bridge/br_stp_bpdu.c
> @@ -230,7 +230,7 @@ void br_stp_rcv(const struct stp_proto *proto, struct sk_buff *skb,
>  			if (net_ratelimit())
>  				br_notice(p->br,
>  					  "port %u config from %pM"
> -					  " (message_age %ul > max_age %ul)\n",
> +					  " (message_age %u > max_age %u)\n",
>  					  p->port_no,
>  					  eth_hdr(skb)->h_source,
>  					  bpdu.message_age, bpdu.max_age);

Could you make the format string a single line plwase.
And add Fixes tag.
