From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 2/2] tcp_cubic: refine Hystart delay threshold
Date: Thu, 4 Dec 2014 19:48:30 -0500
Message-ID: <CADVnQyn=9v3QM0ETNAyFjeUgvy4KgArn4z+YZY-Z-PBEG0wJ0g@mail.gmail.com>
References: <1417738429.22424.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Sangtae Ha <sangtae.ha@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:60086 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933000AbaLEAsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 19:48:32 -0500
Received: by mail-qc0-f169.google.com with SMTP id w7so13601347qcr.0
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 16:48:31 -0800 (PST)
In-Reply-To: <1417738429.22424.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 4, 2014 at 7:13 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> In commit 2b4636a5f8ca ("tcp_cubic: make the delay threshold of HyStart
> less sensitive"), HYSTART_DELAY_MIN was changed to 4 ms.
>
> The remaining problem is that using delay_min + (delay_min/16) as the
> threshold is too sensitive.
>
> 6.25 % of variation is too small for rtt above 60 ms, which are not
> uncommon.
>
> Lets use 12.5 % instead (delay_min + (delay_min/8))

Very nice, Eric!

Acked-by: Neal Cardwell <ncardwell@google.com>
Tested-by: Neal Cardwell <ncardwell@google.com>

neal
