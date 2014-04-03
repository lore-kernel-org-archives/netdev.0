From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/5] netfilter: Fix format string mismatch in
 ip_vs_proto_name()
Date: Thu, 3 Apr 2014 10:37:03 +0900
Message-ID: <20140403013703.GA17467@verge.net.au>
References: <1396280415-31007-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg
To: Masanari Iida <standby24x7@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46689 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933675AbaDCBhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 21:37:06 -0400
Content-Disposition: inline
In-Reply-To: <1396280415-31007-1-git-send-email-standby24x7@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 01, 2014 at 12:40:15AM +0900, Masanari Iida wrote:
> Fix string mismatch in ip_vs_proto_name()
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 4f26ee4..d9da8c4 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -97,7 +97,7 @@ const char *ip_vs_proto_name(unsigned int proto)
>  		return "ICMPv6";
>  #endif
>  	default:
> -		sprintf(buf, "IP_%d", proto);
> +		sprintf(buf, "IP_%u", proto);
>  		return buf;
>  	}
>  }

Thanks, I have queued this up.
