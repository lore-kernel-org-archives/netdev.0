From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 2/3] netdevice: remove useless else keyword
Date: Tue, 06 Aug 2013 10:20:47 +0200
Message-ID: <5200B1DF.2000701@redhat.com>
References: <1375774371-831-1-git-send-email-sakiwit@gmail.com> <1375774371-831-2-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38527 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753040Ab3HFIUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 04:20:51 -0400
In-Reply-To: <1375774371-831-2-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2013 09:32 AM, Jean Sacren wrote:
> Clean up multiple useless else keywords. Add empty lines for
> readability.

Hmm, don't really think this is actually needed or makes things better.

> Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> ---
>   net/core/dev.c | 6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 58eb802..1b0bea8 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1062,9 +1062,11 @@ static int dev_get_valid_name(struct net *net,
>
>   	if (strchr(name, '%'))
>   		return dev_alloc_name_ns(net, dev, name);
> -	else if (__dev_get_by_name(net, name))
> +
> +	if (__dev_get_by_name(net, name))
>   		return -EEXIST;
> -	else if (dev->name != name)
> +
> +	if (dev->name != name)
>   		strlcpy(dev->name, name, IFNAMSIZ);
>
>   	return 0;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
