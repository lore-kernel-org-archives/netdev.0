From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net-next 3/6] net: Introduce IFF_LWT_NETDEV flag
Date: Mon, 08 May 2017 16:11:30 -0400 (EDT)
Message-ID: <20170508.161130.1538627061428691500.davem@davemloft.net>
References: <20170506160734.47084-1-dsahern@gmail.com>
        <20170506160734.47084-4-dsahern@gmail.com>
        <1494233712.2562.0.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsahern@gmail.com, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        nicolas.dichtel@6wind.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38080 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753741AbdEHULc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 16:11:32 -0400
In-Reply-To: <1494233712.2562.0.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 08 May 2017 10:55:12 +0200

> 
>> +static inline bool netif_is_lwd(struct net_device *dev)
>> +{
>> +	return !!(dev->priv_flags & IFF_LWT_NETDEV);
>> +}
> 
> Am I the only one who thinks that this "LWT_NETDEV" vs "LWD" is a bit
> confusing?

Agreed, my old eyes can't discern them at a distance :-)
