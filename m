From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v3 net-next 0/5] ulp: Generalize ULP infrastructure
Date: Tue, 8 Aug 2017 21:23:03 +0100
Message-ID: <6bee85e2-5fb3-135a-ad7c-ae4a350f7148@solarflare.com>
References: <20170807172818.31855-1-tom@quantonium.net>
 <5989D958.6080506@gmail.com>
 <CALx6S37HW6VF1ed5RQx7HCNMGM8pRpb54R1OSFHN8mDNpsc1uQ@mail.gmail.com>
 <598A1146.9090205@gmail.com>
 <CAPDqMer5fh9xKTcA5fuycoOcHaOcFVRnnfEBJYj_Jv1S=R0-xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit Seth <rohit@quantonium.net>,
        Dave Watson <davejwatson@fb.com>
To: Tom Herbert <tom@quantonium.net>,
        John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:45648 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752367AbdHHUXX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 16:23:23 -0400
In-Reply-To: <CAPDqMer5fh9xKTcA5fuycoOcHaOcFVRnnfEBJYj_Jv1S=R0-xQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/17 20:50, Tom Herbert wrote:
> It's a tradeoff. The nice thing about using strings is that we don't
> need maintain a universal enum.
Hmm, that makes it sound as though you're intending for random out-of-tree
 modules to add these things; since if they're in-tree it's easy for them
 to get enum values assigned when they're added.  Do we really want to
 encourage sticking random module code into the network stack like this?

In any case, if you go with the enum approach and later it _does_ prove
 necessary to have more flexibility, you can have enum values dynamically
 assigned (like genetlink manages to do); and programs using the existing
 fixed IDs will continue to work.  It's much harder to go the other way...

-Ed
