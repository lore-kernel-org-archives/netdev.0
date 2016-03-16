From: Nikolay Borisov <kernel@kyup.com>
Subject: Re: ipv6 not bringing up due to qdisc_tx_is_noop failing
Date: Wed, 16 Mar 2016 19:14:26 +0200
Message-ID: <CAJFSNy6Kz8yYWk4J9wHqbkhBoPcjG=rZ89mTDMQ=66njaH9Wag@mail.gmail.com>
References: <56E97BEA.4070004@kyup.com>
	<56E992E0.1080708@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nikolay Borisov <kernel@kyup.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	SiteGround Operations <operations@siteground.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:34879 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598AbcCPRO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 13:14:28 -0400
Received: by mail-oi0-f52.google.com with SMTP id c203so43656102oia.2
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 10:14:28 -0700 (PDT)
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com. [209.85.214.182])
        by smtp.gmail.com with ESMTPSA id j143sm1781557oih.24.2016.03.16.10.14.26
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Mar 2016 10:14:27 -0700 (PDT)
Received: by mail-ob0-f182.google.com with SMTP id ts10so57889711obc.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 10:14:26 -0700 (PDT)
In-Reply-To: <56E992E0.1080708@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2016 at 7:07 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hello,

Hi,

>
> On 16.03.2016 16:29, Nikolay Borisov wrote:
>>
>> I have stack traces which do show this sequence of events, so my
>> questions now are:
>>
>> 1. What's the difference between netdev_queue->qdisc and
>> netdev_queue->qdisc_sleeping. Git blaming indicates those member haves
>> existed even before the git history was started.
>
> qdisc_sleeping is the qdisc you configure before the device is brought up.
> It should transition during carrier up to the normal qdisc.
>
>> 2. Shouldn't the netdev_queue->qdisc also be updated during
>> attach_one_default_qdisc?
>
> Yes, do you have carrier up on your card?

Actually no, the interface indeed shows no carrier yet ibping to other
hosts on the infiniband network works and ibstats shows the link as
being in up state. Do you have any ideas how to debug this further?

>
> Is this a regression, did this work for you and stopped working with a
> specific kernel version?

I don't think this is a regression.

>
> Thanks and bye,
> Hannes
>
