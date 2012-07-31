From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 0/7] Deconstruct struct fib_result
Date: Tue, 31 Jul 2012 10:27:40 -0700
Message-ID: <CAKgT0UcOn48gVsC37hiNCXCP=FwqKjZnjkLviCOW8TVWGkGGVA@mail.gmail.com>
References: <20120727.211814.1628871775065221675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:55249 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353Ab2GaR1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 13:27:40 -0400
Received: by vcbfk26 with SMTP id fk26so6075960vcb.19
        for <netdev@vger.kernel.org>; Tue, 31 Jul 2012 10:27:40 -0700 (PDT)
In-Reply-To: <20120727.211814.1628871775065221675.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 27, 2012 at 9:18 PM, David Miller <davem@davemloft.net> wrote:
>
> This patch set tries to move towards reducing struct fib_result down
> to it's absolute minimum.
>
> The eventual idea is to make it so that fib_lookup() simply
> returns a "struct fib_nh *" and pointer encoded errnos, instead
> of writing into a complicated structure as the return value on
> the stack as is done now.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

I tested these patches most of yesterday and I haven't seen any
issues.  Then again I haven't seen much of an improvement either.

Tested-by: Alexander Duyck <alexander.h.duyck@intel.com>
