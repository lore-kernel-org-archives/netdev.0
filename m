From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v4 3/8] net_sched: mirred: remove action when the
 target device is gone
Date: Mon, 23 Dec 2013 14:51:38 -0800
Message-ID: <CAM_iQpXPLppL1E0d5nFfbM2hzd_-2+zqiU6zpN0b8Xo+XhVHCA@mail.gmail.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387167311-14763-4-git-send-email-xiyou.wangcong@gmail.com>
	<52B1B1B1.2060501@mojatatu.com>
	<CAM_iQpUDZa-=H53Csg8476xOL0xP+rn85O8eB1O39-eF_Jo+uw@mail.gmail.com>
	<52B1FC6D.7040005@mojatatu.com>
	<CAM_iQpWxCShCgiBrraJ3h9qzgVU82quq0E5vmFMSEcgEwSctJQ@mail.gmail.com>
	<52B71024.3090504@mojatatu.com>
	<CAM_iQpW9kUzip+p8fCkD4wH7KbAv8aR-Fqa0iRwPYdzk8+4Tqw@mail.gmail.com>
	<52B74C3A.1050900@mojatatu.com>
	<CAM_iQpXddH4qX2+-mY5gWLU19b6zjZzKV_RvQiyTT8sJ1sq-ow@mail.gmail.com>
	<52B82F80.8070902@mojatatu.com>
	<CAM_iQpUfKcS6RDmV_p+0tEgxx6Z2Y2k9m-VxxwwpL+PB0TX96Q@mail.gmail.com>
	<52B89FEB.9090503@mojatatu.com>
	<CAM_iQpWarY7kHNCtVdYqMVdADFbCUmDsAVQz1+iEx9JKsdZN5w@mail.gmail.com>
	<52B8B98C.7050200@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:55328 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932313Ab3LWWvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 17:51:39 -0500
Received: by mail-oa0-f41.google.com with SMTP id j17so6371452oag.0
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 14:51:39 -0800 (PST)
In-Reply-To: <52B8B98C.7050200@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 23, 2013 at 2:30 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>
> Huh? This has nothing to do with whether you are capable to remove a
> node from a list. It is about you making a decision that the node should
> be removed. You dont have sufficient information to make such a decision.

Then which lacks?

>> Why removing a filter when the netdev is removed is not policy?
>> Actually it is, ONLY that it is not be able to shared with current
>> implementation.
>>
>
> Of course it is. Since you understand that why do you think removing
> an action which is part of that policy is a good idea?
>

Well, I think doing such policy decision for both filters and actions in
kernel IS fine, simply because it is harder for user-space. We already
have many of such policies, they fit well.


>
>> Since you love mechanism _so much_, why not make filters shared
>> by other qdisc's and stop removing them when netdev is gone in kernel?
>>
>> Be realistic, Jamal, user-space is hard, you can't simply let user-space
>> decide everything, especially when you don't provide a simple way to do
>> it.
>> Netlink is already hard to use, even with libnl, since it enforces a cache
>> layer. Sit down and spend some time to write some libnl code, compare it
>> with this patch.
>>
>
> You gotta be joking. I live through this every ither day.

Great! Then show me how to do remove a mirred action upon
the target device is gone in user-space, please?

> Frankly, I think i will have no progress if i tried to convince you the
> world is round. I am dropping from this discussion.
>

Your replies show you care about policy vs mechanism very much,
but you even don't do any thing with either 1) try to show me how
the user-space implements it or 2) go head to make same mechanism
for filters (and qdisc) as well.

Do something to prove that you said. :) Otherwise, I think you are kidding
me.
