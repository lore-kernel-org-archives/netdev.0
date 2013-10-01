From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Established sockets remain open after iface down or address lost
Date: Tue, 1 Oct 2013 23:00:42 +0400
Message-ID: <CAMrnHh5JcK_rHVsiHjHcTy10A+ZLnKp58txsVM_Kj5jSh8CV1Q@mail.gmail.com>
References: <20130926060433.GA9170@cverges-dev-lnx.sentient-energy.com>
	<CAMrnHh6Lr9q27yiSmJ-EbJMTeUVyf9650vK+6QmbfTVfz_omxg@mail.gmail.com>
	<20131001170740.GA9331@cverges-dev-lnx.sentient-energy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: Chris Verges <cverges@sentient-energy.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:34388 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223Ab3JATAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 15:00:43 -0400
Received: by mail-ie0-f172.google.com with SMTP id x13so14895735ief.31
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 12:00:42 -0700 (PDT)
In-Reply-To: <20131001170740.GA9331@cverges-dev-lnx.sentient-energy.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Tue, Oct 1, 2013 at 9:07 PM, Chris Verges
<cverges@sentient-energy.com> wrote:
>  Would you happen to know where any
> out-of-kernel code related to this might be parked if one wanted to
> continue this effort?

Not a big surpize, but reference is in the same thead, I am am doing
cut-n-paste for you:

From: Andi Kleen <andi@xxxxxxxxxxxxxx>
Date: Fri, 19 Oct 2012 13:43:39 -0700

I had a patch for this a long time ago to speed up recovery.
It was very useful with dial on demand ISDN links or DSL
connections that hang up occasionally to force a new IP.

It was in SUSE kernels for a long time, but never made it
into mainline

http://www.firstfloor.org/pub/ak/quilt-before-arch-merge/patches/iff-dynamic

-Andi

Don't forget reference to Andi Kleen in case you push some descendant
of this code
to mainline.
