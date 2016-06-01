From: Greg Rose <gvrose8192@gmail.com>
Subject: Re: [iproute PATCH 1/2] ipaddress: Simplify vf_info parsing
Date: Wed, 1 Jun 2016 15:36:09 -0700
Message-ID: <CALgkqUq8uDErRPMxyDx-M5UQB3v5+tHMyxXpAmK381W_z9KXPg@mail.gmail.com>
References: <1464811430-19415-1-git-send-email-phil@nwl.cc>
	<1464811430-19415-2-git-send-email-phil@nwl.cc>
	<CALgkqUq5nedx+wjEur9WVjvYr0pzvL7CMQmHiVtuuB_1PtOZ2Q@mail.gmail.com>
	<20160601220750.GC2729@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Phil Sutter <phil@nwl.cc>, Greg Rose <gvrose8192@gmail.com>,
	Stephen Hemminger <shemming@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34087 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbcFAWgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 18:36:11 -0400
Received: by mail-io0-f196.google.com with SMTP id l9so4346681ioe.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 15:36:11 -0700 (PDT)
In-Reply-To: <20160601220750.GC2729@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 1, 2016 at 3:07 PM, Phil Sutter <phil@nwl.cc> wrote:
> On Wed, Jun 01, 2016 at 03:00:08PM -0700, Greg Rose wrote:
>> On Wed, Jun 1, 2016 at 1:03 PM, Phil Sutter <phil@nwl.cc> wrote:
>> > Not sure whether I misinterpret commit 7b8179c780a1a, but it looks
>> > overly complicated. Instead rely upon parse_rtattr_nested() to assign
>> > the relevant pointer if requested rtattr fields are present.
>>
>> I'm not sure if newer iproute2 utilities are supposed to work on older
>> kernels but if it is you may want to check this against a 2.6.32
>> kernel.
>
> Yes, it is supposed to. Actually I tried, but the old RHEL6 kernel I
> used didn't export the VF list at all and then I lost motivation.
>
> I didn't check all earlier versions of 7b8179c780a1a, was there a stage
> when it looked like what I'm changing it to?

I don't think so but your patch looks correct - I mean it looks like
it should work.

It's been 5 years since I wrote that original patch and my memory
isn't so great as to why I didn't just do as your patch does but I
think it had something to do with not all drivers reporting a spoof
check value.  However, your patch should handle that case so I see no
reason not to accept it.  Unfortunately I don't have time or the
resources at the moment to check it on an older kernel.

- Greg

>
> Cheers, Phil
