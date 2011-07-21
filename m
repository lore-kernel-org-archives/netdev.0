From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH][TRIVIAL] net, netfilter: Remove redundant goto in
 ebt_ulog_packet
Date: Thu, 21 Jul 2011 14:02:43 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1107211402210.7300@pobox.suse.cz>
References: <alpine.LNX.2.00.1107171953500.32359@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, coreteam@netfilter.org,
	netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	Bart De Schuymer <bart.de.schuymer@pandora.be>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1107171953500.32359@swampdragon.chaosbits.net>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 17 Jul 2011, Jesper Juhl wrote:

> In net/bridge/netfilter/ebt_ulog.c:ebt_ulog_packet() the 'goto unlock'
> before the 'alloc_failure' label is completely redundant. This patch
> removes it.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
>  net/bridge/netfilter/ebt_ulog.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
> index 26377e9..bf2a333 100644
> --- a/net/bridge/netfilter/ebt_ulog.c
> +++ b/net/bridge/netfilter/ebt_ulog.c
> @@ -216,7 +216,6 @@ unlock:
>  nlmsg_failure:
>  	pr_debug("error during NLMSG_PUT. This should "
>  		 "not happen, please report to author.\n");
> -	goto unlock;
>  alloc_failure:
>  	goto unlock;
>  }
> -- 
> 1.7.6
> 
> 
> PS. Please CC me on replies since I'm not subscribed to all the lists 
> copied on this mail.

Doesn't seem to be present in linux-next as of today. I have picked it up.

-- 
Jiri Kosina
SUSE Labs
