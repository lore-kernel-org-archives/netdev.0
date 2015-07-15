From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next 3/3] rhashtable: Add scored lookups
Date: Tue, 14 Jul 2015 17:25:33 -0700
Message-ID: <CALx6S37ce-WF922inJ=JsUEFWL5UiT2=qqDC3UqVGtPFUnpJ+w@mail.gmail.com>
References: <1436917549-3666965-1-git-send-email-tom@herbertland.com>
	<1436917549-3666965-4-git-send-email-tom@herbertland.com>
	<20150715001854.GA29934@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>, Kernel Team <kernel-team@fb.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37546 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813AbbGOAZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 20:25:34 -0400
Received: by igbpg9 with SMTP id pg9so24722573igb.0
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 17:25:33 -0700 (PDT)
In-Reply-To: <20150715001854.GA29934@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 5:18 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Tue, Jul 14, 2015 at 04:45:49PM -0700, Tom Herbert wrote:
>>
>> +             } else if (score == best_score) {
>> +                     matches++;
>> +                     if (reciprocal_scale(khash, matches) == 0)
>> +                             result = he;
>> +                     khash = next_pseudo_random32(khash);
>> +             }
>
> Note that during a rehash you can encounter the same object multiple
> times, does this logic still work in that case?
>
I would think. The property being supported here is uniform
distribution, *not* consistency.

Tom

> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
