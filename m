From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] net: sctp: prevent checksum.h from double
 inclusion
Date: Mon, 1 Jul 2013 16:57:17 -0400
Message-ID: <20130701205717.GC3168@hmsreliant.think-freely.org>
References: <1372695036-10914-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48953 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753269Ab3GAU53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 16:57:29 -0400
Content-Disposition: inline
In-Reply-To: <1372695036-10914-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 01, 2013 at 06:10:36PM +0200, Daniel Borkmann wrote:
> The header file checksum.h is missing proper defines that prevents
> it from double inclusion.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  include/net/sctp/checksum.h | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/include/net/sctp/checksum.h b/include/net/sctp/checksum.h
> index 5a2110d..0cb08e6 100644
> --- a/include/net/sctp/checksum.h
> +++ b/include/net/sctp/checksum.h
> @@ -42,6 +42,9 @@
>   * be incorporated into the next SCTP release.
>   */
>  
> +#ifndef __sctp_checksum_h__
> +#define __sctp_checksum_h__
> +
>  #include <linux/types.h>
>  #include <net/sctp/sctp.h>
>  #include <linux/crc32c.h>
> @@ -81,3 +84,5 @@ static inline __le32 sctp_end_cksum(__u32 crc32)
>  {
>  	return cpu_to_le32(~crc32);
>  }
> +
> +#endif /* __sctp_checksum_h__ */
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
