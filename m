From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH RFC net-next 3/6] net: Introduce IFF_LWT_NETDEV flag
Date: Mon, 8 May 2017 17:57:16 -0700
Message-ID: <52621c1c-57c4-efb7-80dc-648a0da7ae7f@gmail.com>
References: <20170506160734.47084-1-dsahern@gmail.com>
 <20170506160734.47084-4-dsahern@gmail.com>
 <1494233712.2562.0.camel@sipsolutions.net>
 <20170508.161130.1538627061428691500.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        f.fainelli@gmail.com, nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>, johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35660 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751243AbdEIA5U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 20:57:20 -0400
Received: by mail-pg0-f65.google.com with SMTP id i63so12789607pgd.2
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 17:57:20 -0700 (PDT)
In-Reply-To: <20170508.161130.1538627061428691500.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/8/17 1:11 PM, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Mon, 08 May 2017 10:55:12 +0200
> 
>>
>>> +static inline bool netif_is_lwd(struct net_device *dev)
>>> +{
>>> +	return !!(dev->priv_flags & IFF_LWT_NETDEV);
>>> +}
>>
>> Am I the only one who thinks that this "LWT_NETDEV" vs "LWD" is a bit
>> confusing?
> 
> Agreed, my old eyes can't discern them at a distance :-)
> 

perhaps it is the tiny font your old eyes are having trouble with :-)

I am fine with Johannes' suggestion -- just spell it out:
    netif_is_lwt_netdev

where lwt = LightWeighT
