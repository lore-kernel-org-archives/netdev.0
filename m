From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 3/3] vxlan: Remote checksum offload
Date: Mon, 24 Nov 2014 18:50:28 -0800
Message-ID: <CA+mtBx-2gHrFfgWhMjtH=XhyYyYh+57W1YL9x3bUiO8nJjA4YA@mail.gmail.com>
References: <1416873150-12260-1-git-send-email-therbert@google.com>
	<1416873150-12260-4-git-send-email-therbert@google.com>
	<CAEP_g=9_6Rq9Ssr_2q4MKfSDxeL23rbExP5ziHbeCL0Nx-VTvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:42687 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbaKYCu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 21:50:28 -0500
Received: by mail-ie0-f180.google.com with SMTP id rp18so10215950iec.39
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 18:50:28 -0800 (PST)
In-Reply-To: <CAEP_g=9_6Rq9Ssr_2q4MKfSDxeL23rbExP5ziHbeCL0Nx-VTvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2014 at 5:06 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Mon, Nov 24, 2014 at 3:52 PM, Tom Herbert <therbert@google.com> wrote:
>> Add support for remote checksum offload in VXLAN. This commandeers a
>> reserved bit to indicate that RCO is being done, and uses the low order
>> reserved eight bits of the VNI to hold the start and offset values in a
>> compressed manner.
>
> Why do you think that this is OK for you to do? It's clear that there
> is no consensus for this (and in fact there are other proposals that
> use that bit in a different way).

I asked on nvo3 list (which I believe is the appropriate forum) what
the best way to do this is but haven't gotten any response. I will ask
again-- I would assume that with an implementation and data in hand
that might be better basis for discussion.

The flag bit is currently unused in the Linux implementation, so I
don't think it can break anything as of now. I suppose we could make
RCO for VXLAN a config option and possibly change to use a different
if consensus is reached on the right approach in the future.

Tom
