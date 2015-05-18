From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] tcp: add rfc3168, section 6.1.1.1. fallback
Date: Mon, 18 May 2015 14:31:29 +0200
Message-ID: <5559DBA1.3060204@iogearbox.net>
References: <3f31d31107081ed4755ed9731c63a60798c41703.1431892289.git.daniel@iogearbox.net> <1431910796.621.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	=?UTF-8?B?TWlyamEgS8O8aGxld2luZA==?=
	<mirja.kuehlewind@tik.ee.ethz.ch>,
	Brian Trammell <trammell@tik.ee.ethz.ch>,
	Eric Dumazet <edumazet@google.com>,
	Dave That <dave.taht@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43891 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbbERNES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 09:04:18 -0400
In-Reply-To: <1431910796.621.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2015 02:59 AM, Eric Dumazet wrote:
...
> If first SYNACK ECE was delayed (our SYN rtx was spurious), maybe we can
> still keep ECN enabled ?
>
> So maybe do not clear tp->ecn_flags here, as it should be ultimately
> cleared in tcp_ecn_rcv_synack().

Thanks a lot for the feedback, Eric!

We'll be looking into this.

Best,
Daniel
