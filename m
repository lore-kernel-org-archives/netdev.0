From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH] tipc: remove unnecessary call to dev_net()
Date: Wed, 6 Sep 2017 20:50:19 +0800
Message-ID: <d91eb01e-adee-8bce-d419-698020e0af28@windriver.com>
References: <20170906090806.20931-1-kleber.souza@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>
To: Kleber Sacilotto de Souza <kleber.souza@canonical.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:59691 "EHLO
        mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754000AbdIFMwG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 08:52:06 -0400
In-Reply-To: <20170906090806.20931-1-kleber.souza@canonical.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2017 05:08 PM, Kleber Sacilotto de Souza wrote:
> The net device is already stored in the 'net' variable, so no need to call
> dev_net() again.
> 
> Signed-off-by: Kleber Sacilotto de Souza <kleber.souza@canonical.com>

Acked-by: Ying Xue <ying.xue@windriver.com>

> ---
>  net/tipc/bearer.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
> index 89cd061c4468..6d6395e0904e 100644
> --- a/net/tipc/bearer.c
> +++ b/net/tipc/bearer.c
> @@ -661,7 +661,7 @@ static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
>  		break;
>  	case NETDEV_UNREGISTER:
>  	case NETDEV_CHANGENAME:
> -		bearer_disable(dev_net(dev), b);
> +		bearer_disable(net, b);
>  		break;
>  	}
>  	return NOTIFY_OK;
> 
