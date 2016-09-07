From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next V2 0/6] Mellanox 100G mlx5 DCBX CEE and firmware support
Date: Wed, 7 Sep 2016 23:51:56 +0300
Message-ID: <CAJ3xEMiYBv3Z4DaeOnWYJH-3D_bXDUFh_xwOeoTWOxe7MqtZcQ@mail.gmail.com>
References: <1473177852-10711-1-git-send-email-saeedm@mellanox.com>
 <CALzJLG89HjLC9hOR3g2g-SLYyV1K=wM=rHcwv7C=dex1VCOUFQ@mail.gmail.com> <20160907.132703.969714617324713560.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Huy Nguyen <huyn@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34489 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750772AbcIGUv6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 16:51:58 -0400
Received: by mail-oi0-f67.google.com with SMTP id x125so614826oia.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 13:51:57 -0700 (PDT)
In-Reply-To: <20160907.132703.969714617324713560.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 7, 2016 at 11:27 PM, David Miller <davem@davemloft.net> wrote:
> From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
> Date: Wed, 7 Sep 2016 23:16:13 +0300
>
>> Hi Dave, Sorry to bother, but i would like to drop this series for now
>> Huy is working to define and come up with a better mechanism to
>> enable/disable the new DCBX hybrid mode he is adding.
>
> I can't "just drop" any change that's in my tree already.

Dave, I don't see it @ your kernel.org clone but it's not in
patchworks either, so I guess you picked that into your other clone.
If indeed you took it (and I guess this is the case), please note that
was done in spite of a pending reviewer comment
(by me) on the actual necessity of patch #3. If its not possible to
revert them on the non kernel.org clone before you push it to
kernel.org, I guess we need to send you a revert

[1] http://marc.info/?l=linux-netdev&m=147317917622462&w=2

> It is part of the permanent GIT record as I never rebase my trees for
> any reason whatsoever.

> So the best you can do is send me a revert patch.
