From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [net, 2/6] net: korina: define NAPI_WEIGHT
Date: Tue, 17 Jan 2017 10:32:53 -0800
Message-ID: <83caf4f8-1f8a-82d7-3547-664fc1cbaf59@gmail.com>
References: <1484674342-22304-1-git-send-email-roman@advem.lv>
 <20170117.124006.1559010522356313497.davem@davemloft.net>
 <CACiydbLyswWZ2ZX04m22Ga_FBbp-52kxOxBbNcvS+R1d1Kdpcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roman Yeryomin <leroi.lists@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34667 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750846AbdAQSdT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 13:33:19 -0500
Received: by mail-pf0-f194.google.com with SMTP id y143so16751390pfb.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 10:32:56 -0800 (PST)
In-Reply-To: <CACiydbLyswWZ2ZX04m22Ga_FBbp-52kxOxBbNcvS+R1d1Kdpcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2017 10:30 AM, Roman Yeryomin wrote:
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

You need to resend everything and please also provide a cover letter,
and a proper patch subject (e.g: git format-patch --cover-letter
--subject="PATCH net-next v2" a..b)

Thanks!
-- 
Florian
