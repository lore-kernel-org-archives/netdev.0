From: David Miller <davem@davemloft.net>
Subject: Re: Cherry pick commit *net: better skb->sender_cpu and
 skb->napi_id cohabitation* to 4.4 series?
Date: Fri, 02 Jun 2017 14:37:19 -0400 (EDT)
Message-ID: <20170602.143719.124343853677571075.davem@davemloft.net>
References: <20170601.121935.1801387892378122014.davem@davemloft.net>
        <409abefe-62ff-563a-b5c6-a3149ae672e0@molgen.mpg.de>
        <CAM_iQpXg3XCyfi7kStkWOh3R4+0yQHN15MOZ2dkbEYZvR1Xf2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pmenzel@molgen.mpg.de, edumazet@google.com, netdev@vger.kernel.org,
        ast@kernel.org, it+linux-netdev@molgen.mpg.de,
        gregkh@linuxfoundation.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46580 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750918AbdFBShV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 14:37:21 -0400
In-Reply-To: <CAM_iQpXg3XCyfi7kStkWOh3R4+0yQHN15MOZ2dkbEYZvR1Xf2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 2 Jun 2017 10:51:39 -0700

> On Thu, Jun 1, 2017 at 10:32 AM, Paul Menzel <pmenzel@molgen.mpg.de> wrote:
>> Dear David,
>>
>>
>> On 06/01/17 18:19, David Miller wrote:
>>>
>>> Neither of us have anything to do with the 4.4 -stable series.  We only
>>> manage stable backport submissions for the most recent two releases.
>>
>>
>> Thank you for the prompt response. Should the netdev FAQ be updated then to
>> contain that information?
> 
> +1
> 
> It is quite helpful to know which stable releases contain network fixes
> which don't, especially for those who rely on stable releases, at least
> we could do backport by ourselves when we know they are missing.

The people who maintain the -stable releases older than the ones Greg KH
are doing typically scan the ones that Greg applies and tries to integrate
them into their -stable releases when appropriate.

If someone wants to write an accurate description of that and how it works,
and add it to the FAQ, sure.
