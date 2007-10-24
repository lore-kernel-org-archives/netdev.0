From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [2.6 patch] #if 0 sctp_update_copy_cksum()
Date: Wed, 24 Oct 2007 16:30:34 -0400
Message-ID: <471FAB6A.4050204@hp.com>
References: <20071024162407.GD30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, lksctp-developers@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:59748 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755001AbXJXUbL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2007 16:31:11 -0400
In-Reply-To: <20071024162407.GD30533@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> sctp_update_copy_cksum() is no longer used.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

ACK.

-vlad

> 
> ---
> 
>  include/net/sctp/sctp.h |    1 -
>  net/sctp/crc32c.c       |    2 ++
>  2 files changed, 2 insertions(+), 1 deletion(-)
> 
> fc6646f84c07666228166c678ff2b5916db925ed 
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index 119f5a1..93eb708 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -156,7 +156,6 @@ int sctp_primitive_ASCONF(struct sctp_association *, void *arg);
>  __u32 sctp_start_cksum(__u8 *ptr, __u16 count);
>  __u32 sctp_update_cksum(__u8 *ptr, __u16 count, __u32 cksum);
>  __u32 sctp_end_cksum(__u32 cksum);
> -__u32 sctp_update_copy_cksum(__u8 *, __u8 *, __u16 count, __u32 cksum);
>  
>  /*
>   * sctp/input.c
> diff --git a/net/sctp/crc32c.c b/net/sctp/crc32c.c
> index 59cf7b0..181edab 100644
> --- a/net/sctp/crc32c.c
> +++ b/net/sctp/crc32c.c
> @@ -170,6 +170,7 @@ __u32 sctp_update_cksum(__u8 *buffer, __u16 length, __u32 crc32)
>  	return crc32;
>  }
>  
> +#if 0
>  __u32 sctp_update_copy_cksum(__u8 *to, __u8 *from, __u16 length, __u32 crc32)
>  {
>  	__u32 i;
> @@ -186,6 +187,7 @@ __u32 sctp_update_copy_cksum(__u8 *to, __u8 *from, __u16 length, __u32 crc32)
>  
>  	return crc32;
>  }
> +#endif  /*  0  */
>  
>  __u32 sctp_end_cksum(__u32 crc32)
>  {
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

