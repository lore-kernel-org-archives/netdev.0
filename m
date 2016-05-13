From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next v3 1/4] netdevice: add SW statistics ndo
Date: Fri, 13 May 2016 10:17:50 -0700
Message-ID: <1463159870.23934.201.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463151257-3972-1-git-send-email-jiri@resnulli.us>
	 <1463151257-3972-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nogahf@mellanox.com,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, linville@tuxdriver.com, tgraf@suug.ch,
	gospo@cumulusnetworks.com, sfeldma@gmail.com, sd@queasysnail.net,
	eranbe@mellanox.com, ast@plumgrid.com, edumazet@google.com,
	hannes@stressinduktion.org, f.fainelli@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35747 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbcEMRRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 13:17:52 -0400
Received: by mail-pf0-f195.google.com with SMTP id b66so1789635pfb.2
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 10:17:52 -0700 (PDT)
In-Reply-To: <1463151257-3972-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-05-13 at 16:54 +0200, Jiri Pirko wrote:
> From: Nogah Frankel <nogahf@mellanox.com>
]
> +bool dev_have_sw_stats(struct net_device *dev)
> +{
> +	return (dev->netdev_ops->ndo_get_sw_stats64 != NULL);
> +}
> +EXPORT_SYMBOL(dev_have_sw_stats);
> +

2 things : const, and return is not a function.

bool dev_have_sw_stats(const struct net_device *dev)
{
       return dev->netdev_ops->ndo_get_sw_stats64 != NULL;
}
