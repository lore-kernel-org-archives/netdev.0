From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] inet: add IP_BIND_ADDRESS_NO_PORT to overcome
 bind(0) limitations
Date: Sat, 6 Jun 2015 22:30:07 -0400
Message-ID: <CADVnQy=qbyTUdCPvDv8UbcuXJAsNhQVSiJCo83e9k8s8OWOF8w@mail.gmail.com>
References: <1433605985.1895.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:33712 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956AbbFGCaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2015 22:30:08 -0400
Received: by oiha141 with SMTP id a141so11164208oih.0
        for <netdev@vger.kernel.org>; Sat, 06 Jun 2015 19:30:07 -0700 (PDT)
In-Reply-To: <1433605985.1895.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 6, 2015 at 11:53 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
...
> This patch adds a new SOL_IP socket option, asking kernel to ignore
> the 0 port provided by application in bind(IP, port=0) and only
> remember the given IP address.
...
> This new feature is available for both IPv4 and IPv6.

I like this a lot. This addresses a very serious gap in the sockets
API, and should be very useful. The comment mentions that this is
available for IPv6. From skimming the change I would have expected
inet6_bind() would need a change analogous to the change in
inet_bind()? Was there a missing "git add", or is a change to
inet6_bind() somehow not needed?

Thanks!

neal
