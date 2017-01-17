From: David Miller <davem@davemloft.net>
Subject: Re: [net, 2/6] net: korina: define NAPI_WEIGHT
Date: Tue, 17 Jan 2017 14:08:59 -0500 (EST)
Message-ID: <20170117.140859.841742831056887344.davem@davemloft.net>
References: <1484674342-22304-1-git-send-email-roman@advem.lv>
        <20170117.124006.1559010522356313497.davem@davemloft.net>
        <CACiydbLyswWZ2ZX04m22Ga_FBbp-52kxOxBbNcvS+R1d1Kdpcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leroi.lists@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41460 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750987AbdAQTJA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 14:09:00 -0500
In-Reply-To: <CACiydbLyswWZ2ZX04m22Ga_FBbp-52kxOxBbNcvS+R1d1Kdpcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Yeryomin <leroi.lists@gmail.com>
Date: Tue, 17 Jan 2017 20:30:44 +0200

> On 17 January 2017 at 19:40, David Miller <davem@davemloft.net> wrote:
>> From: Roman Yeryomin <leroi.lists@gmail.com>
>> Date: Tue, 17 Jan 2017 19:32:22 +0200
>>
>>> @@ -77,6 +77,8 @@
>>>
>>>  #define MII_CLOCK 1250000    /* no more than 2.5MHz */
>>>
>>> +#define NAPI_WEIGHT  64
>>> +
>>>  /* the following must be powers of two */
>>>  #define KORINA_NUM_RDS       64  /* number of receive descriptors */
>>>  #define KORINA_NUM_TDS       64  /* number of transmit descriptors */
>>> @@ -1080,7 +1082,7 @@ static int korina_probe(struct platform_device *pdev)
>>>       dev->netdev_ops = &korina_netdev_ops;
>>>       dev->ethtool_ops = &netdev_ethtool_ops;
>>>       dev->watchdog_timeo = TX_TIMEOUT;
>>> -     netif_napi_add(dev, &lp->napi, korina_poll, 64);
>>> +     netif_napi_add(dev, &lp->napi, korina_poll, NAPI_WEIGHT);
>>
>> Please use NAPI_POLL_WEIGHT from linux/netdevice.h
> 
> OK, should I resend the whole set or just this one and dependant?

You always must do this for any change whatsoever, a full respin of a
series is always required on any modification whatsoever to any patch.
