From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [for-next 5/6] net/mlx5: Bump driver version
Date: Fri, 26 May 2017 19:35:25 +0300
Message-ID: <CALzJLG_ha-XiPAMnoKrUgm_EwPx2yH0T2y4EBRfrWNYSZi1cTg@mail.gmail.com>
References: <20170523114404.20387-1-saeedm@mellanox.com> <20170523114404.20387-6-saeedm@mellanox.com>
 <3733699c-480b-a1aa-14e1-4f27f86cfead@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        linux-rdma@vger.kernel.org, Ilan Tayari <ilant@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Dennis Dalessandro <dennis.dalessandro@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:34516 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031136AbdEZQfq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 12:35:46 -0400
Received: by mail-qt0-f171.google.com with SMTP id c13so12474452qtc.1
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 09:35:46 -0700 (PDT)
In-Reply-To: <3733699c-480b-a1aa-14e1-4f27f86cfead@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 26, 2017 at 3:56 PM, Dennis Dalessandro
<dennis.dalessandro@intel.com> wrote:
> On 5/23/2017 7:44 AM, Saeed Mahameed wrote:
>>
>> From: Tariq Toukan <tariqt@mellanox.com>
>>
>> Remove date and bump version for mlx5_core driver.
>>
>> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
>> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>
>
> So I just complained about the bnxt_re doing this. I guess I need to raise a
> flag here too. Now to be clear I'm not against doing this version stuff. I'm
> against using it for some internal tracking that is meaningless to the
> kernel community.
>
> There is no detail in your commit message as to what this driver version is
> used for. Can you please explain how your use of driver version is valid
> while theirs is not?
>

Hi Denny,

We don't use this for internal or any kind of tracking at all, if you
look at the driver change log, we hardly touch the version if at all !

but since we decided to remove the date since it is very misleading
and we got some complaints that some think they have an old driver
just because of the date, also we bumped the version so it would align
with our drivers external package (OFED).

Anyway i don't think we are going to change this frequently or even use it.

But if you are that much against touching this ethtool field, why
don't you just jump into the mud and remove it from the tree, I
imagine it is really hard for you to watch for patches doing this and
nack them on the list.

> I realize Dave has already pulled this and I'm not asking for it to be
> reverted but maybe some discussion will help guide future patch submissions
> which do this stuff.
>

Sure, although i don't think we are going to use those version fields
in the future,
please allow me to ask, how do you do your driver versioning ? how do
you track things ?
and what is your future vision regarding ethool->drv_version ?

Thanks,
Saeed.

> -Denny
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
