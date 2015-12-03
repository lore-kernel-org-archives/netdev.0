From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next v3 04/28] net: add netif_is_team_master helper
Date: Thu, 03 Dec 2015 04:46:01 -0800
Message-ID: <1449146761.6379.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
	 <1449141150-8172-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36308 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760219AbbLCMqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 07:46:04 -0500
Received: by pacdm15 with SMTP id dm15so68687599pac.3
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 04:46:03 -0800 (PST)
In-Reply-To: <1449141150-8172-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-12-03 at 12:12 +0100, Jiri Pirko wrote:

>   *	struct net_device - The DEVICE structure.
> @@ -3887,6 +3890,11 @@ static inline bool netif_is_ovs_master(const struct net_device *dev)
>  	return dev->priv_flags & IFF_OPENVSWITCH;
>  }
>  
> +static inline bool netif_is_team_master(struct net_device *dev)
> +{
> +	return dev->priv_flags & IFF_TEAM;
> +}
> +

Please add 'const' qualifiers whenever possible, like for
netif_is_ovs_master(const struct net_device *dev)
