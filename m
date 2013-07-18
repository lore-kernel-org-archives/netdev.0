From: Fernando Soto <fernando.soto@gmail.com>
Subject: Re: WARNING: at net/core/dst.c:274 dst_release+0x2d/0x56()
Date: Thu, 18 Jul 2013 11:55:28 -0400
Message-ID: <CADCFf2gS3sS0hL1pr-P+LUVqhvBEMLy-Q8hRp-R8c06e4qtp2g@mail.gmail.com>
References: <CADCFf2jAJRiHgMaMs8tNWSaonPmXg6q5C66iisdpuz9yMSAV+w@mail.gmail.com>
	<1372799622.4979.22.camel@edumazet-glaptop>
	<CADCFf2hEzwgtqfn4nHc4VwgT2+_XW9=uAos7Qo5YsEpRCWFO5Q@mail.gmail.com>
	<CADCFf2iUeyhnfhHET2Tbi1bM+7h=2LXLFvcerXHsz3Xv6E6zLw@mail.gmail.com>
	<1372950494.4979.97.camel@edumazet-glaptop>
	<CADCFf2gS=m_X2WOVGdgUoKyGgdn1sD9HsBYhjikeMN05RExrOQ@mail.gmail.com>
	<CADCFf2jzs+41uKD9RjotXpqSRDoJnSFY90LVKt2UeQfUF05Wrg@mail.gmail.com>
	<1374083689.6097.19.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:39349 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932148Ab3GRPz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 11:55:29 -0400
Received: by mail-ob0-f182.google.com with SMTP id va7so3904555obc.13
        for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 08:55:28 -0700 (PDT)
In-Reply-To: <1374083689.6097.19.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

I applied the patch to the latest 3.10.1 and the network is working
fine. I'm not sure if it is due to the patch or any other changes
between 3.10.0 and 3.10.1.
I'll leave iperf running for a few days. Looks good so far.

Thank you!

Fernando

On Wed, Jul 17, 2013 at 1:54 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-07-17 at 09:19 -0400, Fernando Soto wrote:
>> Hi Eric,
>>
>> Just to let you know that I have performed same tests with 3.4.52 and
>> it works fine.
>> Kernel 3.10 had another issue that prevented me from running the same
>> tests: network dies as soon as I launch iperf - no kernel errors, but
>> it simply doesn't work.
>> I'll stick to 3.4.52. Thanks for your help.
>
> This might be relevant : http://patchwork.ozlabs.org/patch/259596/
>
>
