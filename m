From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next V1 1/3] net: Add max rate tx queue attribute
Date: Mon, 16 Mar 2015 14:37:03 -0700
Message-ID: <CALx6S368X286GRkT9mS9T5AQ7megmux-2HA1yhF0eh=EBCFL6A@mail.gmail.com>
References: <1426150405-7904-1-git-send-email-ogerlitz@mellanox.com>
	<1426150405-7904-2-git-send-email-ogerlitz@mellanox.com>
	<20150315.010727.1396856705582316764.davem@davemloft.net>
	<550537C2.3080107@mellanox.com>
	<5507368E.6030107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, matanb@mellanox.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:38645 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932632AbbCPVhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 17:37:04 -0400
Received: by igbue6 with SMTP id ue6so55685414igb.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 14:37:03 -0700 (PDT)
In-Reply-To: <5507368E.6030107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 1:01 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 15/03/15 00:41, Or Gerlitz wrote:
>> On 3/15/2015 7:07 AM, David Miller wrote:
>>> From: Or Gerlitz <ogerlitz@mellanox.com>
>>> This is more succinctly expressed as:
>>>
>>>     err = -EOPNOTSUPP;
>>>     if (dev->netdev_ops->ndo_set_tx_maxrate) {
>>>         err = dev->netdev_ops->ndo_set_tx_maxrate(dev, index, rate);
>>>     if (!err) {
>>>         queue->tx_maxrate = rate;
>>>         return len;
>>>     }
>>>     return err;
>>>
>>
>> sure, I'll fix that.
>
> Can you also include a patch which updates the sysfs documentation at
> Documentation/ABI/testing/sysfs-class-net-queues? Thanks!

As well as Documentation/networking/scaling.txt.

Thanks,
Tom


> --
> Florian
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
