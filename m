From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [MAC802154] DRAFT: IEEE 802.15.4 MAC layer basic implementation
Date: Wed, 30 Nov 2011 19:54:53 +0300
Message-ID: <CAJmB2rAPFWtP1qMqNfgN-Xb154E1=QwXWc4XgKxrGdmKxUqANQ@mail.gmail.com>
References: <20111130141827.GA3739@avtobot.cybertron>
	<CALT56yPPXzVH9Mb6LznEyRv42wgGWK_P7Yf8cbWywD4HXtFGTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jon Smirl <jonsmirl@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:32965 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751493Ab1K3Qyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 11:54:55 -0500
Received: by lagw12 with SMTP id w12so184387lag.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 08:54:53 -0800 (PST)
In-Reply-To: <CALT56yPPXzVH9Mb6LznEyRv42wgGWK_P7Yf8cbWywD4HXtFGTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dmitry,

thank you for the reply,

2011/11/30 Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>:
> Hello colleagues,
>
> On Wed, Nov 30, 2011 at 6:18 PM, Alexander Smirnov
> <alex.bluesman.smirnov@gmail.com> wrote:
>
> [skipped]
>
>> This stack has working implementation in 'linux-zigbee.sourceforge.net'
>> project, but unfortunately all the development was freezed according to
>> unknown issue and it hasn't been merged to mailnline.
>>
>> Currently I'm the one engineer who continue working on them. So the
>> following patch series is based on the project mentioned above, and I just
>> cut code into roudimentary pieces with minor fixes.
>
> Alexander, thank you for continuing the work on the project! I'm glad to see
> those patches being submitted to the mainline kernel.
>
>> The code in the following patches was tested by 6LowPAN module. I took at230
>> transciever driver from 'linux-zigbee' and brought up IPv6 network, it worked.
>>
>> Could please anyone review patches and let me know what do you think?
>
> Several global notes:
>
> 1) Could you please include any (virtual or real) device driver
> implementing the stack.
> There was a "virtual radio" driver written for SoftMAC devices. The
> driver had some small
> design problems, but I think the stripped down version can be included
> in the patchset.

do you think that's a good idea to mix several layers in one patch series?
Won't it be better to push some basic MAC support and only after the drivers?
I see that way a little bit easier for code review.

But if you don't think so, it's not a problem.
>
> 2) Could you please rearrange the patches a little bit:
> I'd really like to see the "monitor" devices interface pushed in the
> first round of the patches.
> It depends only on "simple mlme" and "RX/TX datapath" patches IIRC. It
> would be really
> good to merge those things first as it would then allow one to
> implement their drivers,
> check the radio, capture radio frames, etc.
>

Hmm, sounds good. I agree with this roadmap. :)

> I'll try reviewing patches really soon (as the time permits). However
> could you please specify,
> your changes over the last state I pushed to sf.net git repos (devel
> or devel-30 branches)
> to ease review?
>

The changes are really small and they don't affect the code
structure/logic: using of common style in debug output, rewrite
'fetch_skb' functions, remove several unused lines etc...

> --
> With best wishes
> Dmitry

With best regards,
Alexander
