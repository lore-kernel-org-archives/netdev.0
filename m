From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 0/5] mlx4 misc fixes and improvements
Date: Mon, 19 Sep 2016 08:32:49 +0300
Message-ID: <CAJ3xEMi-4nNxDf3pBrDwenN50BTFtTT0+cMF62BMHYPK9WvZrg@mail.gmail.com>
References: <1473686416-11779-1-git-send-email-tariqt@mellanox.com>
 <20160915.192106.739428651744920778.davem@davemloft.net> <80a8e8c5-689e-a2b1-e2d4-817dc0649385@gmail.com>
 <20160918.220046.1374771296032853447.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tariq Toukan <ttoukan.linux@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34342 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755785AbcISFcu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 01:32:50 -0400
Received: by mail-oi0-f65.google.com with SMTP id a62so337074oib.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 22:32:50 -0700 (PDT)
In-Reply-To: <20160918.220046.1374771296032853447.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 5:00 AM, David Miller <davem@davemloft.net> wrote:
> From: Tariq Toukan <ttoukan.linux@gmail.com>
> Date: Sun, 18 Sep 2016 10:27:23 +0300
>
>> Hi Dave,
>>
>> On 16/09/2016 2:21 AM, David Miller wrote:
>>> From: Tariq Toukan <tariqt@mellanox.com>
>>> Date: Mon, 12 Sep 2016 16:20:11 +0300
>>>
>>>> This patchset contains some bug fixes, a cleanup, and small
>>>> improvements
>>>> from the team to the mlx4 Eth and core drivers.
>>>>
>>>> Series generated against net-next commit:
>>>> 02154927c115 "net: dsa: bcm_sf2: Get VLAN_PORT_MASK from b53_device"
>>>>
>>>> Please push the following patch to -stable  >= 4.6 as well:
>>>> "net/mlx4_core: Fix to clean devlink resources"
>>> Again, coding style fixes and optimizations like branch prediction
>>> hints are not bug fixes and therefore not appropriate for 'net'.
>> Yes, I know. Please notice that it was submitted to net-next this
>> time.
>
> This is completely incompatible with a request for one of the changes
> to go into -stable.
>
> If the change is not in 'net', it can't go to -stable.

Dave,

So when we're pretty late in the 4.8-rc cycle, a fix for a problem
which was not introduced in 4.8-rc1 was targeted to net-next (4.9) and
not net.

This indeed creates a small mess when the fix needs to go to -stable as well.

I guess the correct thing to do next time, would be to either send to
net and ask you to take it to stable as part of picking the patch --
or send to net-next, and later send you a request to put it to stable
-- or, wait a bit and send it to net of the next kernel along with
stable request... we will pick one of these three way of doings next
(...) time.

So, at this point, I think it would be just correct to take the series
to net-next, and on a future point we'll issue a request to push the
patch into stable.

Or.

Or.
