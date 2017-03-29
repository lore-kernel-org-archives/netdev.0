From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: add support for NETDEV_RESEND_IGMP event
Date: Tue, 28 Mar 2017 22:02:56 -0700 (PDT)
Message-ID: <20170328.220256.2102183367030293945.davem@davemloft.net>
References: <1490726956-25965-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41732 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752630AbdC2FDR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 01:03:17 -0400
In-Reply-To: <1490726956-25965-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Tue, 28 Mar 2017 14:49:16 -0400

> This patch adds support for NETDEV_RESEND_IGMP event similar
> to how it works for IPv4.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Applied, but:

> +void igmp6_late_cleanup(void)
> +{
> +	unregister_netdevice_notifier(&igmp6_netdev_notifier);
> +}
> +
> -- 
> 2.7.4
> 

Do not add empty lines at the end of files like this.

Thanks.
