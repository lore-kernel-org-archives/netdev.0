From: Ashwani Wason <ashwas@gmail.com>
Subject: Re: [PATCH] tcp: Fix a connect() race with timewait sockets
Date: Wed, 2 Dec 2009 08:05:51 -0800
Message-ID: <fd1a5ee40912020805r7a490ea2mdf7dc8597b9973b8@mail.gmail.com>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com>
	<4B152F97.1090409@gmail.com> <20091202.005937.177088443.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, kdakhane@gmail.com, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, zbr@ioremap.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:34886 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753822AbZLBQGF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 11:06:05 -0500
In-Reply-To: <20091202.005937.177088443.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both reuse and recycle were enabled for this test. (I know because we,
Kapil and I are working together on different aspects of this.)

- Ashwani



On Wed, Dec 2, 2009 at 12:59 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 01 Dec 2009 16:00:39 +0100
>
>> [PATCH] tcp: Fix a connect() race with timewait sockets
>
> This condition would only trigger if the timewait recycling sysctl is
> enabled.
>
> It is off by default, and I can't find any mention in this bug report
> that it has been turned on.
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
