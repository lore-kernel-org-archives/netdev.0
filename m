From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: [net-next PATCH 1/5] be2net: Use cancel_delayed_work_sync instead
 of cancel_delayed_work()
Date: Wed, 10 Jun 2009 16:21:11 +0400
Message-ID: <4A2FA537.7080709@bigtelecom.ru>
References: <20090610121835.GA16411@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:46925 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756561AbZFJMVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 08:21:11 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 2C223A6C2CC
	for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 16:21:06 +0400 (MSD)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id J5Zv2jIKBfyE for <netdev@vger.kernel.org>;
	Wed, 10 Jun 2009 16:21:05 +0400 (MSD)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTPA id 2331BA6C204
	for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 16:21:05 +0400 (MSD)
In-Reply-To: <20090610121835.GA16411@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Typo in desctription:

"Use cancel_delayed_work_sycn" -> "Use cancel_delayed_work_sync"

Thanks

> Use cancel_delayed_work_sycn instead of cancel_delayed_work() to reliably kill be_worker() as it rearms itself.
>
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>
> ---
>  drivers/net/benet/be_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
> index 347d002..69046a1 100644
> --- a/drivers/net/benet/be_main.c
> +++ b/drivers/net/benet/be_main.c
> @@ -1533,7 +1533,7 @@ static int be_close(struct net_device *netdev)
>  	struct be_eq_obj *tx_eq = &adapter->tx_eq;
>  	int vec;
>  
> -	cancel_delayed_work(&adapter->work);
> +	cancel_delayed_work_sync(&adapter->work);
>  
>  	netif_stop_queue(netdev);
>  	netif_carrier_off(netdev);
>   

