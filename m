From: Veaceslav Falico <darkmag@gmail.com>
Subject: Re: [PATCH v2 net-next 07/27] net: add for_each iterators through
 neighbour lower link's private
Date: Wed, 11 Sep 2013 07:37:59 +0200
Message-ID: <CAE3RKNmGd0npZ0gXUf=hx5C0DPOWutXJnAy-HoJBqRjFFkTjLw@mail.gmail.com>
References: <1378846691-9717-1-git-send-email-vfalico@redhat.com>
 <1378846691-9717-8-git-send-email-vfalico@redhat.com> <l0oi1g$jo6$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:62194 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753880Ab3IKFiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 01:38:20 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so8714695pdi.13
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 22:38:19 -0700 (PDT)
In-Reply-To: <l0oi1g$jo6$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 11, 2013 at 3:46 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, 10 Sep 2013 at 20:57 GMT, Veaceslav Falico <vfalico@redhat.com> wrote:
>> +void *netdev_lower_get_next_private_rcu(struct net_device *dev,
>> +                                     struct list_head **iter)
>> +{
>> +     struct netdev_adjacent *lower;
>> +
>> +     WARN_ON_ONCE(!rcu_read_lock_held());
>> +
>
> Since this function has _rcu suffix, this warning is not useful at all.

I've been using it to catch offenders, just in case, like BUG_ON.

I can easily remove it, if needed, there are *tons* of cleanups
that can be made for this patchset, tbh, I've just left it the way it
is to be able to catch bug/review easier :).

p.s. Please, use reply-all when replying...

-- 
Best regards,
Veaceslav Falico
