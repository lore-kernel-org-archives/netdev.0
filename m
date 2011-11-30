From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [MAC802154] DRAFT: IEEE 802.15.4 MAC layer basic implementation
Date: Wed, 30 Nov 2011 21:17:19 +0400
Message-ID: <CALT56yOzVPPR-YXAqg7UeXiRg-RAk=gjYRfTh0bZEHQb5iwq6A@mail.gmail.com>
References: <20111130141827.GA3739@avtobot.cybertron>
	<CALT56yPPXzVH9Mb6LznEyRv42wgGWK_P7Yf8cbWywD4HXtFGTA@mail.gmail.com>
	<CAJmB2rAPFWtP1qMqNfgN-Xb154E1=QwXWc4XgKxrGdmKxUqANQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jon Smirl <jonsmirl@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53821 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757888Ab1K3RRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 12:17:20 -0500
Received: by faaq16 with SMTP id q16so677265faa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 09:17:19 -0800 (PST)
In-Reply-To: <CAJmB2rAPFWtP1qMqNfgN-Xb154E1=QwXWc4XgKxrGdmKxUqANQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Nov 30, 2011 at 8:54 PM, Alexander Smirnov
<alex.bluesman.smirnov@gmail.com> wrote:
> 2011/11/30 Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>:
>> On Wed, Nov 30, 2011 at 6:18 PM, Alexander Smirnov
>> <alex.bluesman.smirnov@gmail.com> wrote:
>>
>> [skipped]
>>
>>> This stack has working implementation in 'linux-zigbee.sourceforge.net'
>>> project, but unfortunately all the development was freezed according to
>>> unknown issue and it hasn't been merged to mailnline.
>>>
>>> Currently I'm the one engineer who continue working on them. So the
>>> following patch series is based on the project mentioned above, and I just
>>> cut code into roudimentary pieces with minor fixes.
>>
>> Alexander, thank you for continuing the work on the project! I'm glad to see
>> those patches being submitted to the mainline kernel.
>>
>>> The code in the following patches was tested by 6LowPAN module. I took at230
>>> transciever driver from 'linux-zigbee' and brought up IPv6 network, it worked.
>>>
>>> Could please anyone review patches and let me know what do you think?
>>
>> Several global notes:
>>
>> 1) Could you please include any (virtual or real) device driver
>> implementing the stack.
>> There was a "virtual radio" driver written for SoftMAC devices. The
>> driver had some small
>> design problems, but I think the stripped down version can be included
>> in the patchset.
>
> do you think that's a good idea to mix several layers in one patch series?
> Won't it be better to push some basic MAC support and only after the drivers?
> I see that way a little bit easier for code review.
>
> But if you don't think so, it's not a problem.

I think it's a good thing to include at least one sample driver (event
if it's a fake one).

>>
>> 2) Could you please rearrange the patches a little bit:
>> I'd really like to see the "monitor" devices interface pushed in the
>> first round of the patches.
>> It depends only on "simple mlme" and "RX/TX datapath" patches IIRC. It
>> would be really
>> good to merge those things first as it would then allow one to
>> implement their drivers,
>> check the radio, capture radio frames, etc.
>>
>
> Hmm, sounds good. I agree with this roadmap. :)

You might be interested in checking a MiWi protocols (from Microchip
IIRC). One of them was an IEEE 802.15.4 based protocol with lot's of
features stirpped out (I think you can find documentation in some of
the Microchip applicaiton notes, I either left the docs in Siemens, or I
have them in my home, I'll check later). That not-so-standard might
be a good 'second step' on the path to full IEEE 802.15.4 compliance.

>
>> I'll try reviewing patches really soon (as the time permits). However
>> could you please specify,
>> your changes over the last state I pushed to sf.net git repos (devel
>> or devel-30 branches)
>> to ease review?
>>
>
> The changes are really small and they don't affect the code
> structure/logic: using of common style in debug output, rewrite
> 'fetch_skb' functions, remove several unused lines etc...

Fine with me then.

-- 
With best wishes
Dmitry
