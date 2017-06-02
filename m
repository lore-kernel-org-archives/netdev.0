From: Paul Menzel <pmenzel@molgen.mpg.de>
Subject: Re: Cherry pick commit *net: better skb->sender_cpu and skb->napi_id
 cohabitation* to 4.4 series?
Date: Fri, 02 Jun 2017 23:37:13 +0200
Message-ID: <8a1f02849ee8e65bd8799c65c9bee622@molgen.mpg.de>
References: <20170601.121935.1801387892378122014.davem@davemloft.net>
 <409abefe-62ff-563a-b5c6-a3149ae672e0@molgen.mpg.de>
 <CAM_iQpXg3XCyfi7kStkWOh3R4+0yQHN15MOZ2dkbEYZvR1Xf2Q@mail.gmail.com>
 <20170602.143719.124343853677571075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, edumazet@google.com,
        netdev@vger.kernel.org, ast@kernel.org,
        it+linux-netdev@molgen.mpg.de, gregkh@linuxfoundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.molgen.mpg.de ([141.14.17.11]:59769 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750966AbdFBVhQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Jun 2017 17:37:16 -0400
In-Reply-To: <20170602.143719.124343853677571075.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David,


On 2017-06-02 20:37, David Miller wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Fri, 2 Jun 2017 10:51:39 -0700
> 
>> On Thu, Jun 1, 2017 at 10:32 AM, Paul Menzel <pmenzel@molgen.mpg.de> 
>> wrote:

>>> On 06/01/17 18:19, David Miller wrote:
>>>> 
>>>> Neither of us have anything to do with the 4.4 -stable series.  We 
>>>> only
>>>> manage stable backport submissions for the most recent two releases.
>>> 
>>> 
>>> Thank you for the prompt response. Should the netdev FAQ be updated 
>>> then to
>>> contain that information?
>> 
>> +1
>> 
>> It is quite helpful to know which stable releases contain network 
>> fixes
>> which don't, especially for those who rely on stable releases, at 
>> least
>> we could do backport by ourselves when we know they are missing.
> 
> The people who maintain the -stable releases older than the ones Greg 
> KH
> are doing typically scan the ones that Greg applies and tries to 
> integrate
> them into their -stable releases when appropriate.

My understanding is, that Greg maintains the 4.4 (LTS) and 4.9 (LTS) 
series.

> If someone wants to write an accurate description of that and how it 
> works,
> and add it to the FAQ, sure.

I can do that, when I understand the policy.


Kind regards,

Paul
