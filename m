From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute2] tc: flower: Fix parsing ip address
Date: Wed, 22 Feb 2017 16:16:32 +0100
Message-ID: <20170222151631.GA8047@penelope.horms.nl>
References: <1487772301-22303-1-git-send-email-roid@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Shahar Klein <shahark@mellanox.com>,
        Mark Bloch <markb@mellanox.com>, Jiri Pirko <jiri@mellanox.com>
To: Roi Dayan <roid@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36351 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933061AbdBVPQm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 10:16:42 -0500
Received: by mail-wm0-f51.google.com with SMTP id v77so1291745wmv.1
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 07:16:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1487772301-22303-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 22, 2017 at 04:05:01PM +0200, Roi Dayan wrote:
> Fix order of arguments when passed to __flower_parse_ip_addr.
> 
> Fixes: ("f888f4e20534 tc: flower: Support matching ARP")
> Signed-off-by: Roi Dayan <roid@mellanox.com>
> Reviewed-by: Paul Blakey <paulb@mellanox.com>

Reviewed-by: Simon Horman <simon.horman@netronome.com>

> ---
>  tc/f_flower.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/tc/f_flower.c b/tc/f_flower.c
> index 6bd03f2..5aac4a0 100644
> --- a/tc/f_flower.c
> +++ b/tc/f_flower.c
> @@ -289,8 +289,8 @@ static int flower_parse_ip_addr(char *str, __be16 eth_type,
>  		return -1;
>  	}
>  
> -	return __flower_parse_ip_addr(str, family, addr4_type, addr6_type,
> -				      mask4_type, mask6_type, n);
> +	return __flower_parse_ip_addr(str, family, addr4_type, mask4_type,
> +				      addr6_type, mask6_type, n);
>  }
>  
>  static bool flower_eth_type_arp(__be16 eth_type)
> -- 
> 2.7.4
> 
