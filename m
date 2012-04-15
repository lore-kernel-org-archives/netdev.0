From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][trivial] ipv4: fix checkpatch errors
Date: Sun, 15 Apr 2012 12:38:51 -0400 (EDT)
Message-ID: <20120415.123851.786816332832233291.davem@davemloft.net>
References: <1334489681-4662-1-git-send-email-dbaluta@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, trivial@kernel.org,
	linux-kernel@vger.kernel.org
To: dbaluta@ixiacom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334489681-4662-1-git-send-email-dbaluta@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: dbaluta@ixiacom.com
Date: Sun, 15 Apr 2012 14:34:41 +0300

> From: Daniel Baluta <dbaluta@ixiacom.com>
> 
> Fix checkpatch errors of the following type:
> 	* ERROR: "foo * bar" should be "foo *bar"
> 	* ERROR: "(foo*)" should be "(foo *)"
> 
> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>

Applied, but:

> @@ -216,7 +216,7 @@ static struct rtnl_link_stats64 *ipgre_get_stats64(struct net_device *dev,
>  
>  /* Given src, dst and key, find appropriate for input tunnel. */
>  
> -static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
> +static struct ip_tunnel *ipgre_tunnel_lookup(struct net_device *dev,
>  					      __be32 remote, __be32 local,
>  					      __be32 key, __be16 gre_proto)
>  {

I had to reindent these function arguments on the lines after the one
you modified so that they continue to line up properly with the column
of the openning parenthesis on the previous line.

Do not blindly make checkpatch fixes without taking into consideration
the indentation modifications necessary in the context around your
change.
