From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net] tcp: make challenge acks less predictable
Date: Sun, 10 Jul 2016 08:55:57 -0400
Message-ID: <CADVnQym7nL8AekOFYFH3pcnLerHBAC4BrYv5hY6Z5HN7kGkVkQ@mail.gmail.com>
References: <1467995586.30694.34.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAPzkZjz1R_T8q75LXLBc91j7YrngxdPc-o2Hpz+4YYyoWLantA@mail.gmail.com>
 <1468052160.30694.51.camel@edumazet-glaptop3.roam.corp.google.com> <1468137842.30694.58.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yue Cao <ycao009@ucr.edu>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Zhiyun Qian <zhiyunq@cs.ucr.edu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:34095 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797AbcGJM41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 08:56:27 -0400
Received: by mail-oi0-f49.google.com with SMTP id s66so115632922oif.1
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2016 05:56:27 -0700 (PDT)
In-Reply-To: <1468137842.30694.58.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 10, 2016 at 4:04 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> From: Eric Dumazet <edumazet@google.com>
>
> Yue Cao claims that current host rate limiting of challenge ACKS
> (RFC 5961) could leak enough information to allow a patient attacker
> to hijack TCP sessions. He will soon provide details in an academic
> paper.
>
> This patch increases the default limit from 100 to 1000, and adds
> some randomization so that the attacker can no longer hijack
> sessions without spending a considerable amount of probes.
>
> Based on initial analysis and patch from Linus.
>
> Note that we also have per socket rate limiting, so it is tempting
> to remove the host limit in the future.
>
> v2: randomize the count of challenge acks per second, not the period.
>
> Fixes: 282f23c6ee34 ("tcp: implement RFC 5961 3.2")
> Reported-by: Yue Cao <ycao009@ucr.edu>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks, Eric!

neal
