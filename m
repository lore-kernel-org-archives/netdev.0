From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 4/4] sctp: fix comment in chunk.c
Date: Fri, 25 Oct 2013 19:45:41 -0400
Message-ID: <526B02A5.50500@gmail.com>
References: <1382665805-13952-1-git-send-email-wangweidong1@huawei.com> <1382665805-13952-5-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>, davem@davemloft.net,
	nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:35304 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684Ab3JYXpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 19:45:49 -0400
In-Reply-To: <1382665805-13952-5-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2013 09:50 PM, Wang Weidong wrote:
> fix a spelling
>
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

You could have combined these spelling fixes into 1 patch.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   net/sctp/chunk.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
> index 7bd5ed4..f2044fc 100644
> --- a/net/sctp/chunk.c
> +++ b/net/sctp/chunk.c
> @@ -201,7 +201,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
>
>   	max = asoc->frag_point;
>   	/* If the the peer requested that we authenticate DATA chunks
> -	 * we need to accound for bundling of the AUTH chunks along with
> +	 * we need to account for bundling of the AUTH chunks along with
>   	 * DATA.
>   	 */
>   	if (sctp_auth_send_cid(SCTP_CID_DATA, asoc)) {
>
