From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] inet: add IP_BIND_ADDRESS_NO_PORT to overcome
 bind(0) limitations
Date: Sat, 06 Jun 2015 20:08:02 -0700
Message-ID: <1433646482.29864.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1433605985.1895.84.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CADVnQy=qbyTUdCPvDv8UbcuXJAsNhQVSiJCo83e9k8s8OWOF8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34537 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbbFGDIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2015 23:08:05 -0400
Received: by iebmu5 with SMTP id mu5so44326344ieb.1
        for <netdev@vger.kernel.org>; Sat, 06 Jun 2015 20:08:04 -0700 (PDT)
In-Reply-To: <CADVnQy=qbyTUdCPvDv8UbcuXJAsNhQVSiJCo83e9k8s8OWOF8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-06-06 at 22:30 -0400, Neal Cardwell wrote:

> I like this a lot. This addresses a very serious gap in the sockets
> API, and should be very useful. The comment mentions that this is
> available for IPv6. From skimming the change I would have expected
> inet6_bind() would need a change analogous to the change in
> inet_bind()? Was there a missing "git add", or is a change to
> inet6_bind() somehow not needed?

Hmm... No I totally missed inet6_bind(), thanks for spotting this.

I'll add a IPv6 mode to my test program before sending a v2.

Thanks Neal.
