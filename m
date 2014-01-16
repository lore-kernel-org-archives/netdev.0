From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] sctp: remove the unnecessary assignment
Date: Thu, 16 Jan 2014 07:18:31 -0500
Message-ID: <20140116121831.GB9984@hmsreliant.think-freely.org>
References: <52D7976F.7070708@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42474 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768AbaAPMSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 07:18:41 -0500
Content-Disposition: inline
In-Reply-To: <52D7976F.7070708@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 04:25:19PM +0800, Wang Weidong wrote:
> When go the right path, the status is 0, no need to assign it again.
> So just remove the assignment.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/sctp/protocol.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 7c16108..d6934dc 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -1461,7 +1461,6 @@ static __init int sctp_init(void)
>  	if (status)
>  		goto err_v6_add_protocol;
>  
> -	status = 0;
>  out:
>  	return status;
>  err_v6_add_protocol:
> -- 
> 1.7.12
> 
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
