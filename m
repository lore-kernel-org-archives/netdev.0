From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH RFC 2/3] ipv4: make flow functions more grepable by
 removing flowi4_update_output
Date: Mon, 13 Jun 2016 16:03:58 -0600
Message-ID: <814da6cb-cb7f-ee72-718c-3bb0fd14753d@cumulusnetworks.com>
References: <1465850858-8559-1-git-send-email-hannes@stressinduktion.org>
 <1465850858-8559-3-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35316 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422700AbcFMWEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 18:04:01 -0400
Received: by mail-pa0-f43.google.com with SMTP id hl6so49510040pac.2
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 15:04:00 -0700 (PDT)
In-Reply-To: <1465850858-8559-3-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/13/16 2:47 PM, Hannes Frederic Sowa wrote:
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/net/flow.h              | 11 -----------
>  include/net/route.h             |  8 ++++----
>  net/netfilter/ipvs/ip_vs_xmit.c |  9 +++++++--
>  net/sctp/protocol.c             | 10 ++++------
>  4 files changed, 15 insertions(+), 23 deletions(-)
>
> diff --git a/include/net/flow.h b/include/net/flow.h
> index 2c8e95b987c98c..6276a81f7b3d13 100644
> --- a/include/net/flow.h
> +++ b/include/net/flow.h
> @@ -90,17 +90,6 @@ struct flowi4 {
>  #define fl4_gre_key		uli.gre_key
>  } __attribute__((__aligned__(BITS_PER_LONG/8)));
>
> -/* Reset some input parameters after previous lookup */
> -static inline void flowi4_update_output(struct flowi4 *fl4, int oif, __u8 tos,
> -					__be32 daddr, __be32 saddr)
> -{
> -	fl4->flowi4_oif = oif;
> -	fl4->flowi4_tos = tos;
> -	fl4->daddr = daddr;
> -	fl4->saddr = saddr;
> -}
> -				
> -

Ditto with this helper. Glad to see it go.

Change LGTM. Reviewed-by: David Ahern <dsa@cumulusnetworks.com>
