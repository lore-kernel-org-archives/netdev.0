From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [PATCH 3/3] vhost: fix the wrong log descriptions
Date: Mon, 18 Nov 2013 21:12:22 +0800
Message-ID: <CAEH94LgTBWqG6At_rbYLkEEp9RSn+RiJPwT7uKzdcu_+7cKhDw@mail.gmail.com>
References: <1384744763-7476-1-git-send-email-zwu.kernel@gmail.com>
	<1384744763-7476-3-git-send-email-zwu.kernel@gmail.com>
	<20131118101833.GD3559@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:63947 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582Ab3KRNMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 08:12:23 -0500
Received: by mail-oa0-f54.google.com with SMTP id h16so1079949oag.41
        for <netdev@vger.kernel.org>; Mon, 18 Nov 2013 05:12:22 -0800 (PST)
In-Reply-To: <20131118101833.GD3559@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 18, 2013 at 6:18 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Mon, Nov 18, 2013 at 11:19:23AM +0800, Zhi Yong Wu wrote:
>> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>
>> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>
> This one does not make sense to me.
> Heads in avail ring are heads which according to Guest are available by
> definition.
ok, please ignore this patch
>
>
>> ---
>>  drivers/vhost/vhost.c  |    2 +-
>>  drivers/vhost/vringh.c |    2 +-
>>  2 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>> index 78987e4..568d20f 100644
>> --- a/drivers/vhost/vhost.c
>> +++ b/drivers/vhost/vhost.c
>> @@ -1241,7 +1241,7 @@ int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
>>
>>       /* If their number is silly, that's an error. */
>>       if (unlikely(head >= vq->num)) {
>> -             vq_err(vq, "Guest says index %u > %u is available",
>> +             vq_err(vq, "Guest says index %u > %u is unavailable",
>>                      head, vq->num);
>>               return -EINVAL;
>>       }
>> diff --git a/drivers/vhost/vringh.c b/drivers/vhost/vringh.c
>> index 5174eba..86ef6c4 100644
>> --- a/drivers/vhost/vringh.c
>> +++ b/drivers/vhost/vringh.c
>> @@ -57,7 +57,7 @@ static inline int __vringh_get_head(const struct vringh *vrh,
>>       }
>>
>>       if (head >= vrh->vring.num) {
>> -             vringh_bad("Guest says index %u > %u is available",
>> +             vringh_bad("Guest says index %u > %u is unavailable",
>>                          head, vrh->vring.num);
>>               return -EINVAL;
>>       }
>> --
>> 1.7.6.5



-- 
Regards,

Zhi Yong Wu
