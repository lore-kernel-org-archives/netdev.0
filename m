From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCHv3] pktgen: Convert return type of process_ipsec to bool
Date: Thu, 28 May 2015 12:11:02 +0200
Message-ID: <20150528121102.566576af@redhat.com>
References: <1432786265-31021-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, ast@plumgrid.com,
	stephen@networkplumber.org, fabf@skynet.be, joe@perches.com,
	sd@queasysnail.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, brouer@redhat.com
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432786265-31021-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 May 2015 00:11:05 -0400
Nicholas Krause <xerofoify@gmail.com> wrote:

> This converts the function, process_ipsec to the 
> return type of bool due to only returning either
> one or zero.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
> v3
> Move the v2 changes below the sign off line for this patch.
> v2
> Change incorrect patch subject and make commit message
> clearer
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

When doing this change, could you please align the above line to the
open parenthesis of process_ipsec (even-though it was also misaligned
before).

scripts/checkpatch.pl will tell you:
 CHECK: Alignment should match open parenthesis	

Did anyone tell you that kernel developers nitpick? ;-)

And usually you don't need to Cc the "main" Linux Kernel Mailing List
(linux-kernel@vger.kernel.org) with a trivial patch like this.  Sending
it to the network developers should be enough (netdev@vger.kernel.org).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
