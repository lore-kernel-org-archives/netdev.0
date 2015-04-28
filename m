From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] tcp: add tcpi_bytes_received to
 tcp_info
Date: Tue, 28 Apr 2015 16:07:59 -0700
Message-ID: <1430262479.3711.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430260098-14127-1-git-send-email-edumazet@google.com>
	 <1430260098-14127-3-git-send-email-edumazet@google.com>
	 <CAK6E8=f9toHqhTNzU3y7NwJy1tQE99EZoLkppNYOMgmSEniztQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Matt Mathis <mattmathis@google.com>,
	Eric Salo <salo@google.com>, Martin Lau <kafai@fb.com>,
	Chris Rapier <rapier@psc.edu>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:35516 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030966AbbD1XIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 19:08:04 -0400
Received: by igbyr2 with SMTP id yr2so105039854igb.0
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 16:08:03 -0700 (PDT)
In-Reply-To: <CAK6E8=f9toHqhTNzU3y7NwJy1tQE99EZoLkppNYOMgmSEniztQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-28 at 15:56 -0700, Yuchung Cheng wrote:

> Acked-by: Yuchung Cheng <ycheng@google.com>
> 

Thanks !

> tho I slightly prefer to call tcp_rcv_nxt_update() when rcv_nxt is
> updated in TFO for consistency.

Right, but is the tp->rcv_nxt prior value even valid at this point ? :)

Anyway, this would need to make tcp_rcv_nxt_update() non static and
would convince compiler to not inline the code.

At this point, we can simply set tp->bytes_received.
