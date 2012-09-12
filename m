From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 4/4] ipv6: use DST_* macro to set obselete
 field
Date: Wed, 12 Sep 2012 09:40:31 +0200
Message-ID: <1347435631.13103.691.camel@edumazet-glaptop>
References: <504DFF90.3010802@6wind.com>
	 <1347350987-8054-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1347350987-8054-5-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, davem@davemloft.net, sds@tycho.nsa.gov,
	james.l.morris@oracle.com, eparis@parisplace.org, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51640 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732Ab2ILHkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 03:40:36 -0400
In-Reply-To: <1347350987-8054-5-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-09-11 at 10:09 +0200, Nicolas Dichtel wrote:
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/ipv6/route.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 561f249..0c6f132 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -226,7 +226,7 @@ static struct rt6_info ip6_null_entry_template = {
>  	.dst = {
>  		.__refcnt	= ATOMIC_INIT(1),
>  		.__use		= 1,
> -		.obsolete	= -1,
> +		.obsolete	= DST_OBSOLETE_FORCE_CHK,
>  		.error		= -ENETUNREACH,
>  		.input		= ip6_pkt_discard,
>  		.output		= ip6_pkt_discard_out,
> @@ -246,7 +246,7 @@ static struct rt6_info ip6_prohibit_entry_template = {
>  	.dst = {
>  		.__refcnt	= ATOMIC_INIT(1),
>  		.__use		= 1,
> -		.obsolete	= -1,
> +		.obsolete	= DST_OBSOLETE_FORCE_CHK,
>  		.error		= -EACCES,
>  		.input		= ip6_pkt_prohibit,
>  		.output		= ip6_pkt_prohibit_out,
> @@ -261,7 +261,7 @@ static struct rt6_info ip6_blk_hole_entry_template = {
>  	.dst = {
>  		.__refcnt	= ATOMIC_INIT(1),
>  		.__use		= 1,
> -		.obsolete	= -1,
> +		.obsolete	= DST_OBSOLETE_FORCE_CHK,
>  		.error		= -EINVAL,
>  		.input		= dst_discard,
>  		.output		= dst_discard,

Acked-by: Eric Dumazet <edumazet@google.com>
