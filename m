From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [Linux-v4.4-LTS] ppp: Backport of rtnetlink device handling
Date: Fri, 8 Jan 2016 10:28:39 +0100
Message-ID: <CA+icZUWrK+jO7PBkvRqHQoNJEDsGgzHnM1fod+zzXdKXWHdHCg@mail.gmail.com>
References: <CA+icZUXJwvr7k1xrEy1w_Fw4D3V-LA7dKfDa0gxHHmNu3XY=kw@mail.gmail.com>
	<20160104125528.GB1267@alphalink.fr>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:33587 "EHLO
	mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754398AbcAHJ2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 04:28:40 -0500
Received: by mail-vk0-f46.google.com with SMTP id i129so50504610vkb.0
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 01:28:40 -0800 (PST)
In-Reply-To: <20160104125528.GB1267@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 4, 2016 at 1:55 PM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> On Mon, Jan 04, 2016 at 08:47:30AM +0100, Sedat Dilek wrote:
>> Hi Guillaume,
>>
>> which patches do I need to backport "ppp: rtnetlink device handling"
>> to Linux v4.4 which will be a LongTerm-Supported (LTS) Linux-kernel
>> [0]?
>>
> Quite frankly, backporting this series doesn't look like a good idea.
> It only provides a new ABI for creating ppp devices and your control
> plane most likely hasn't been updated to use it. So it won't bring any
> benefit.
>

What do you mean by "control plane"?

>> I tried [1] and [2] on top of recent net-next Git tree which will be
>> in Linux v4.5.
>> Currently, your patches are not included in net-next.git#master.
>>
> Indeed, and that's why no control plane should rely on them (yet).
>

Again, what do you mean by "control plane"?

Does anything speak against to have these patches for upcoming Linux v4.5?
AFAICS, the merge-window will open next week.

>> In the thread "[net-next] ppp: rtnetlink device handling" [4] you
>> explained the benefits and use-case etc.
>>
>> Checking with git-log shows me these commits...
>>
>> $ git log --oneline --no-merges v4.4-rc8.. drivers/net/ppp net/l2tp
>> 19e8c5713e78 l2tp: rely on ppp layer for skb scrubbing
>> 645eee4eba45 ppp: implement rtnetlink device handling
>> 3a9bce0ae138 ppp: define reusable device creation functions
>> 69d9728d00c7 ppp: declare ppp devices as enumerated interfaces
>> 94dbffe16eb1 ppp: define "ppp" device type
>> 681b4d88ad8e pppox: use standard module auto-loading feature
>> a8acce6aa584 ppp: remove PPPOX_ZOMBIE socket state
>> 8734e485fed5 ppp: don't set sk_state to PPPOX_ZOMBIE in pppoe_disc_rcv()
>>
>> ...is that sufficient for a backport?
>>
> Applying the series directly on v4.4-rc8 should work (with a few
> conflicts, but other patches are unrelated). But still, you probably
> don't want to maintain backports unless strictly required. BTW, this
> one has no chance to hit any -stable tree anyway.

I know about the "rules" for -stable.

As far as I understood you, no pre-conditional changes to the
net-infrastructure are required.
I haven't tested to apply above series.

Thanks for your explanations.

- Sedat -
