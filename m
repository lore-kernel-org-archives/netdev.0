From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHv2] pktgen: Convert return type of process_ipsec to bool
Date: Wed, 27 May 2015 21:08:46 -0700
Message-ID: <1432786126.2846.196.camel@perches.com>
References: <1432785621-30921-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, brouer@redhat.com, edumazet@google.com,
	ast@plumgrid.com, stephen@networkplumber.org, fabf@skynet.be,
	sd@queasysnail.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432785621-30921-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-05-28 at 00:00 -0400, Nicholas Krause wrote:
> This converts the function, process_ipsec to the 
> return type of bool due to only returning either
> one or zero.
> v2
> Change incorrect patch subject and make commit message
> clearer
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---

The V2 changelog delta goes here below the --- line
Not in the commit message area.

TrySend a v3
>  net/core/pktgen.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 508155b..33bdb76 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -2587,7 +2587,7 @@ static void free_SAs(struct pktgen_dev *pkt_dev)
>  	}
>  }
>  
> -static int process_ipsec(struct pktgen_dev *pkt_dev,
> +static bool process_ipsec(struct pktgen_dev *pkt_dev,
>  			      struct sk_buff *skb, __be16 protocol)
>  {
>  	if (pkt_dev->flags & F_IPSEC_ON) {
> @@ -2626,10 +2626,10 @@ static int process_ipsec(struct pktgen_dev *pkt_dev,
>  			ip_send_check(iph);
>  		}
>  	}
> -	return 1;
> +	return true;
>  err:
>  	kfree_skb(skb);
> -	return 0;
> +	return false;
>  }
>  #endif
>  
