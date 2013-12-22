From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v4 3/8] net_sched: mirred: remove action when the
 target device is gone
Date: Sun, 22 Dec 2013 13:11:56 -0800
Message-ID: <CAM_iQpXddH4qX2+-mY5gWLU19b6zjZzKV_RvQiyTT8sJ1sq-ow@mail.gmail.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387167311-14763-4-git-send-email-xiyou.wangcong@gmail.com>
	<52B1B1B1.2060501@mojatatu.com>
	<CAM_iQpUDZa-=H53Csg8476xOL0xP+rn85O8eB1O39-eF_Jo+uw@mail.gmail.com>
	<52B1FC6D.7040005@mojatatu.com>
	<CAM_iQpWxCShCgiBrraJ3h9qzgVU82quq0E5vmFMSEcgEwSctJQ@mail.gmail.com>
	<52B71024.3090504@mojatatu.com>
	<CAM_iQpW9kUzip+p8fCkD4wH7KbAv8aR-Fqa0iRwPYdzk8+4Tqw@mail.gmail.com>
	<52B74C3A.1050900@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:55461 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755402Ab3LVVL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 16:11:57 -0500
Received: by mail-oa0-f52.google.com with SMTP id h16so5013024oag.11
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 13:11:57 -0800 (PST)
In-Reply-To: <52B74C3A.1050900@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 22, 2013 at 12:31 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 12/22/13 14:42, Cong Wang wrote:
>>
>> On Sun, Dec 22, 2013 at 8:15 AM, Jamal Hadi Salim <jhs@mojatatu.com>
>> wrote:
>
>
>> You know qdiscs and filters are removed too when the device
>> is gone, right? So isn't that also a policy you are talking about?
>>
>
> That is an easy optimization that made sense to make - we
> deleted the root of a graph. No need to spam the policy manager.
> What we are talking about is deleting a faulty node shared
> by multiple graphs and deleting the vertex but then leaving
> dangling edges around. Doesnt make sense.
> No action that is shared between two flows or devices is EVER
> going to be removed because you deleted a qdisc or a netdev.

NOTHING you talked about here is relevant to the policy or
mechanism you talked previously. Just correctness.

If removing an shared action is impossible, what about non-shared
ones? Actually for my _own_ use case, I even don't use nor care
about shared one...
