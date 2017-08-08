From: Tom Herbert <tom@quantonium.net>
Subject: Re: [PATCH v3 net-next 0/5] ulp: Generalize ULP infrastructure
Date: Tue, 8 Aug 2017 14:08:35 -0700
Message-ID: <CAPDqMerc5ZH+6N6vRvJBShPM-mMrh2Sd+p-+gG1q63jrdZO3TQ@mail.gmail.com>
References: <20170807172818.31855-1-tom@quantonium.net> <5989D958.6080506@gmail.com>
 <CALx6S37HW6VF1ed5RQx7HCNMGM8pRpb54R1OSFHN8mDNpsc1uQ@mail.gmail.com>
 <598A1146.9090205@gmail.com> <CAPDqMer5fh9xKTcA5fuycoOcHaOcFVRnnfEBJYj_Jv1S=R0-xQ@mail.gmail.com>
 <6bee85e2-5fb3-135a-ad7c-ae4a350f7148@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: John Fastabend <john.fastabend@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit Seth <rohit@quantonium.net>,
        Dave Watson <davejwatson@fb.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:35424 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752154AbdHHVIh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 17:08:37 -0400
Received: by mail-wr0-f170.google.com with SMTP id k71so17259227wrc.2
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 14:08:36 -0700 (PDT)
In-Reply-To: <6bee85e2-5fb3-135a-ad7c-ae4a350f7148@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 8, 2017 at 1:23 PM, Edward Cree <ecree@solarflare.com> wrote:
> On 08/08/17 20:50, Tom Herbert wrote:
>> It's a tradeoff. The nice thing about using strings is that we don't
>> need maintain a universal enum.
> Hmm, that makes it sound as though you're intending for random out-of-tree
>  modules to add these things; since if they're in-tree it's easy for them
>  to get enum values assigned when they're added.  Do we really want to
>  encourage sticking random module code into the network stack like this?
>
> In any case, if you go with the enum approach and later it _does_ prove
>  necessary to have more flexibility, you can have enum values dynamically
>  assigned (like genetlink manages to do); and programs using the existing
>  fixed IDs will continue to work.  It's much harder to go the other way...
>
There is history and precedence. The string mechanism for ulp_ops  a
direct port of the original ULP infrastructure done for kTLS. That
code based the mechanism on TCP congestion ops and that was introduced
into the kernel twelve years ago. This method doesn't seem to have
been viewed as a problem before now...

Tom

> -Ed
