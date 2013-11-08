From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/5] sctp: remove the else path
Date: Fri, 08 Nov 2013 22:19:37 +0300
Message-ID: <527D3949.2000302@cogentembedded.com>
References: <1383879310-22792-1-git-send-email-wangweidong1@huawei.com> <1383879310-22792-3-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>, vyasevich@gmail.com,
	nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:33322 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756614Ab3KHSTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 13:19:47 -0500
Received: by mail-la0-f42.google.com with SMTP id ep20so2097331lab.29
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 10:19:45 -0800 (PST)
In-Reply-To: <1383879310-22792-3-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/08/2013 05:55 AM, Wang Weidong wrote:

> Make the code more simplification.

> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>   net/sctp/associola.c | 4 +---
>   1 file changed, 1 insertion(+), 3 deletions(-)

> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 667f984..2d53d4c 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -954,15 +954,13 @@ int sctp_cmp_addr_exact(const union sctp_addr *ss1,
>    */
>   struct sctp_chunk *sctp_get_ecne_prepend(struct sctp_association *asoc)
>   {
> -	struct sctp_chunk *chunk;
> +	struct sctp_chunk *chunk = NULL;
>
>   	/* Send ECNE if needed.
>   	 * Not being able to allocate a chunk here is not deadly.
>   	 */
>   	if (asoc->need_ecne)
>   		chunk = sctp_make_ecne(asoc, asoc->last_ecne_tsn);
> -	else
> -		chunk = NULL;

    This is hardly better/simpler than it was.

WBR, Sergei
