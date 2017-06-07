From: Jes Sorensen <jes.sorensen@gmail.com>
Subject: Re: [PATCH 7/7] mlx5: Do not build eswitch_offloads if
 CONFIG_MLX5_EN_ESWITCH_OFFLOADS is set
Date: Wed, 7 Jun 2017 11:19:43 -0400
Message-ID: <7a5d0385-5e5e-114d-5064-f380b749d00c@gmail.com>
References: <20170526211624.23133-1-jsorensen@fb.com>
 <20170526211624.23133-8-jsorensen@fb.com>
 <CAJ3xEMgeBaE9q6sucXtOQTBLAvZvf_d0eGvMsGbVa2vWc21R-Q@mail.gmail.com>
 <e7c36f4e-788a-89dd-e92e-e6a31004758a@gmail.com>
 <CAJ3xEMh8ALo9Pgb0sh5dzAFaPtiKDaZyEhgasgi40Pba1JzCQA@mail.gmail.com>
 <c5b3bd3d-b5de-8b0b-34ff-068a1b3bd31c@fb.com>
 <CAJ3xEMhKjPwg75hO8af7XDL5JPoxkq2AtpL61CtOLb-T4aACWQ@mail.gmail.com>
 <aed5b35a-3467-7e01-6f14-e70ea4a94832@fb.com>
 <CALzJLG-=WU8DFNkqjAKBSFjHyc1V2YvoWV4r7fG9QVSRTybgZw@mail.gmail.com>
 <34ee6c6c-e509-40d0-77f7-a5ac451139a7@fb.com>
 <CALzJLG9oK-g9J6OunfqLsqppAPZMWjWXNSfXnP3OdsnnhaaCxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Jes Sorensen <jsorensen@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f193.google.com ([209.85.213.193]:33886 "EHLO
        mail-yb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750920AbdFGPTq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 11:19:46 -0400
Received: by mail-yb0-f193.google.com with SMTP id o185so554303yba.1
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 08:19:46 -0700 (PDT)
In-Reply-To: <CALzJLG9oK-g9J6OunfqLsqppAPZMWjWXNSfXnP3OdsnnhaaCxg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2017 12:06 AM, Saeed Mahameed wrote:
> On Wed, Jun 7, 2017 at 12:46 AM, Jes Sorensen <jsorensen@fb.com> wrote:
>>> Hey Jes,
>>>
>>> It is not just about squashing patches, I am working on a series of
>>> patches to allow compiling out eswitch/eswitch_offloads/en_rep.c/en_tc
>>> altogether, it will come out cleaner as it will remove all ethernet
>>> sriov/eswitch VF representors and eswitch tc offloads stuff with one
>>> kconfig flag, and yet preserve standard QoS functionality from en_tc.
>>
>>
>> Saeed,
>>
>> I realize it is not just about squashing patches, however doing that to
>> someone else's patches is just broken. The Linux kernel way is to build on
>> top of patches, if they are valid, rather than throwing them all away and
>> doing it from scratch again bottom up. If there was something actually wrong
>> with my patches, and I would love to understand if that is the case, since I
>> don't know 1/100th of the hardware details that you know, then please share
>> those details.
> 
> Hey Jes,
> 
> Sorry for the inconvenience, I am working on a very similar patches,
> even before you posted yours.
> Your patches are fine, but as i said before, removing eswitch as is
> will introduce a small regression in Multi-PF configuration.
> 
> the issue is that lately we are having tons of discussions exactly
> about this and how to do the driver breakdown
> that makes everyone happy, so things are moving relatively slow, but
> my work on eswitch is converging.

Gotcha. I deliberately didn't disable eswitch itself in my patch, but 
only the offloading functionality, because of the old discussion 
mentioning that the eswitch needing to be initialized.

>> Sounds good.
>>
>>> I will post some patches for you to review by end of week.
>>
>>
>> Could we please start seeing this stuff happen in a public git tree so it is
>> possible to follow and contribute to the development? It is very frustrating
>> having to wait for things to appear and and not knowing whether a patch is
>> integrated or needs to be revised when you have things building on top of
>> it.
> 
> Sure, I will post some patches later today.
> I believe they will be fully ready by for submission by End of week.
> Again sorry about this.

Awesome!

Jes
