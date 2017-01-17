From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: Re: [net, 2/6] net: korina: define NAPI_WEIGHT
Date: Tue, 17 Jan 2017 20:30:44 +0200
Message-ID: <CACiydbLyswWZ2ZX04m22Ga_FBbp-52kxOxBbNcvS+R1d1Kdpcw@mail.gmail.com>
References: <1484674342-22304-1-git-send-email-roman@advem.lv> <20170117.124006.1559010522356313497.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f180.google.com ([209.85.217.180]:35575 "EHLO
        mail-ua0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751042AbdAQSaz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 13:30:55 -0500
Received: by mail-ua0-f180.google.com with SMTP id y9so109684069uae.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 10:30:55 -0800 (PST)
In-Reply-To: <20170117.124006.1559010522356313497.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 January 2017 at 19:40, David Miller <davem@davemloft.net> wrote:
> From: Roman Yeryomin <leroi.lists@gmail.com>
> Date: Tue, 17 Jan 2017 19:32:22 +0200
>
>> @@ -77,6 +77,8 @@
>>
>>  #define MII_CLOCK 1250000    /* no more than 2.5MHz */
>>
>> +#define NAPI_WEIGHT  64
>> +
>>  /* the following must be powers of two */
>>  #define KORINA_NUM_RDS       64  /* number of receive descriptors */
>>  #define KORINA_NUM_TDS       64  /* number of transmit descriptors */
>> @@ -1080,7 +1082,7 @@ static int korina_probe(struct platform_device *pdev)
>>       dev->netdev_ops = &korina_netdev_ops;
>>       dev->ethtool_ops = &netdev_ethtool_ops;
>>       dev->watchdog_timeo = TX_TIMEOUT;
>> -     netif_napi_add(dev, &lp->napi, korina_poll, 64);
>> +     netif_napi_add(dev, &lp->napi, korina_poll, NAPI_WEIGHT);
>
> Please use NAPI_POLL_WEIGHT from linux/netdevice.h

OK, should I resend the whole set or just this one and dependant?

Regards,
Roman
