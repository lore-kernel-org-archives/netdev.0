From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] [NIU] VLAN does not work with niu driver
Date: Wed, 9 Sep 2009 14:35:14 -0700
Message-ID: <20090909143514.0bd1e7ba@nehalam>
References: <4AA819D8.1020306@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joyce.Yu@sun.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44903 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753816AbZIIVfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2009 17:35:17 -0400
In-Reply-To: <4AA819D8.1020306@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 09 Sep 2009 14:10:48 -0700
Joyce Yu <Joyce.Yu@sun.com> wrote:

> From: Joyce Yu <joyce.yu@sun.com>
> Date: Wed, 9 Sep 2009 08:43:00 -0700
> Subject: [PATCH] VLAN does not work with niu driver
>  Signed-off-by: Joyce Yu <joyce.yu@sun.com>
> 
> ---
>  drivers/net/niu.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/niu.h b/drivers/net/niu.h
> index 3bd0b59..35678db 100644
> --- a/drivers/net/niu.h
> +++ b/drivers/net/niu.h
> @@ -2700,7 +2700,7 @@ struct fcram_hash_ipv6 {
>  #define RCR_PKT_TYPE_UDP               0x2
>  #define RCR_PKT_TYPE_SCTP              0x3
> 
> -#define NIU_RXPULL_MAX                 ETH_HLEN
> +#define NIU_RXPULL_MAX                 64
> 
>  struct rx_pkt_hdr0 {
>  #if defined(__LITTLE_ENDIAN_BITFIELD)
> --
> 1.6.4
> 

Shouldn't the vlan driver being doing pskb_may_pull()
or pskb_pull() instead?

-- 
