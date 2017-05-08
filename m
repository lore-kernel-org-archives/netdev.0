From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH RFC net-next 3/6] net: Introduce IFF_LWT_NETDEV flag
Date: Mon, 08 May 2017 10:55:12 +0200
Message-ID: <1494233712.2562.0.camel@sipsolutions.net>
References: <20170506160734.47084-1-dsahern@gmail.com>
         <20170506160734.47084-4-dsahern@gmail.com>
         (sfid-20170506_180801_641452_79C549AB)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        nicolas.dichtel@6wind.com
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:58486 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753161AbdEHIzP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 04:55:15 -0400
In-Reply-To: <20170506160734.47084-4-dsahern@gmail.com> (sfid-20170506_180801_641452_79C549AB)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +static inline bool netif_is_lwd(struct net_device *dev)
> +{
> +	return !!(dev->priv_flags & IFF_LWT_NETDEV);
> +}

Am I the only one who thinks that this "LWT_NETDEV" vs "LWD" is a bit
confusing?

Is "netif_is_lwt_netdev()" really too long?

johannes
