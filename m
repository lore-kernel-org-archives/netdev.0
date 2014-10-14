From: Eric Dumazet <edumazet@gmail.com>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better TCP_SKB_CB
 layout to reduce cache line misses
Date: Tue, 14 Oct 2014 14:03:51 -0700
Message-ID: <CAFrEnejET5wer6S6qx13tMKWMshmRj+JnQeZL-zdPGcs__9NoQ@mail.gmail.com>
References: <CAHA+R7N9rNUH4aytFG3YLt8nzpERqmf34FgaWbe5R7P0AaWuZw@mail.gmail.com>
	<20141014.150300.536881166743492994.davem@davemloft.net>
	<CAFrEnehWNzmzZGV-ZGbZF=wJ1q0TjFtB1yG6Dp1yVrJmBj9B7Q@mail.gmail.com>
	<20141014.164705.1874094084240216813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: cwang@twopensource.com, kkolasa@winsoft.pl,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:58991 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752944AbaJNVDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 17:03:52 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so8666941pad.1
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 14:03:52 -0700 (PDT)
In-Reply-To: <20141014.164705.1874094084240216813.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-10-14 13:47 GMT-07:00 David Miller <davem@davemloft.net>:
>
>
> > Patch looks good, but seems a net-next candidate to me.
>
> I thought it is a potential fix for this corruption report?


Sure, but a one liner fix seemed more obvious, as it points to the problem.

I do not particularly care, as long as we fixed the bug.

Thanks !
