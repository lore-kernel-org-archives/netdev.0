From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: Fix RPF to work with policy routing
Date: Thu, 22 Oct 2009 23:30:19 -0700
Message-ID: <55a4f86e0910222330l7eda29ffr9949b9a635c97649@mail.gmail.com>
References: <1255867954.4815.25.camel@dogo.mojatatu.com>
	 <1255868019.4815.27.camel@dogo.mojatatu.com>
	 <20091022.214943.105371652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: hadi@cyberus.ca, netdev@vger.kernel.org, atis@mikrotik.com,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:35056 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbZJWGaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 02:30:16 -0400
Received: by fxm18 with SMTP id 18so9984013fxm.37
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2009 23:30:20 -0700 (PDT)
In-Reply-To: <20091022.214943.105371652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In most of the use cases I've seen marking packets has been far from
symmetric (of course: not that this is representative of anything).
Although, to be fair, most of the time this is because packets in only
direction (usually trasmit) were even being marked in the first place.

However, I do agree that .mark should be explicitly initialized (or a
comment about it being left =0 inserted in the same location).

On Thu, Oct 22, 2009 at 21:49, David Miller <davem@davemloft.net> wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Sun, 18 Oct 2009 08:13:39 -0400
>
>> On Sun, 2009-10-18 at 08:12 -0400, jamal wrote:
>>> policy routing never worked with mark.
>>
>> I meant policy routing, mark and RPF never worked together ;->
>
> Is this actually valid?
>
> Such a change has a built-in assumption, I think, that
> marks are symmetric.
>
> Just because we ended up with mark X on input doesn't mean
> that the reverse path route exists with mark X too.
>
> In fact I can't even see a valid way to specify a mark for
> the RPF lookup.
>
> Maybe you can convince me otherwise :-)
>
