From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 04/28] net: add netif_is_team_master helper
Date: Thu, 3 Dec 2015 14:49:10 +0100
Message-ID: <20151203134910.GJ2331@nanopsycho.orion>
References: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
 <1449141150-8172-5-git-send-email-jiri@resnulli.us>
 <1449146761.6379.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:34545 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759904AbbLCNtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 08:49:13 -0500
Received: by wmvv187 with SMTP id v187so28035217wmv.1
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 05:49:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1449146761.6379.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 03, 2015 at 01:46:01PM CET, eric.dumazet@gmail.com wrote:
>On Thu, 2015-12-03 at 12:12 +0100, Jiri Pirko wrote:
>
>>   *	struct net_device - The DEVICE structure.
>> @@ -3887,6 +3890,11 @@ static inline bool netif_is_ovs_master(const struct net_device *dev)
>>  	return dev->priv_flags & IFF_OPENVSWITCH;
>>  }
>>  
>> +static inline bool netif_is_team_master(struct net_device *dev)
>> +{
>> +	return dev->priv_flags & IFF_TEAM;
>> +}
>> +
>
>Please add 'const' qualifiers whenever possible, like for
>netif_is_ovs_master(const struct net_device *dev)

Okay, will do. Thanks.
