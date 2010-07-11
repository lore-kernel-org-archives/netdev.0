From: Felipe W Damasio <felipewd@gmail.com>
Subject: Re: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Sun, 11 Jul 2010 00:11:20 -0300
Message-ID: <AANLkTilQbM8F27a5SLZLMzndLYfz-eRhzyxP18KCFz2K@mail.gmail.com>
References: <1278695580.2696.55.camel@edumazet-laptop>
	<AANLkTil39xHOhcdAo4h_jWtx_UuYdFHGdQVAdwPMd7QJ@mail.gmail.com>
	<1278742649.2538.17.camel@edumazet-laptop>
	<20100710.123011.260095467.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, kaber@trash.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100710.123011.260095467.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mr. Miller,

2010/7/10 David Miller <davem@davemloft.net>:
> It could be corruption from elsewhere. =A0Those last four hex
> digits (0x5d415d41) are "]A]A" in ascii, but that could just
> be coincidence.

What do you mean "from elsewhere"? You mean elsewhere on the network co=
de?

Since the function that had the problem was tcp_recvmsg and we're
talking about a squid process, we're either talking about a typical
webserver-objet response, or about about an incorrect/faulty http
request from the user.

Like I told Mr. Dumazet, since on the squid logs I got a:

2010/07/08 14:51:10| clientTryParseRequest: FD 6088
(187.16.240.122:2035) Invalid Request

Only a second before the bug entry on syslog, I suppose that this
invalid request caused the problem (more like a guess, really).

If you think there's a way I can help reproduce/trigger and fix this
bug, please let me know, since the production machine is down until I
can ensure my bosses that this particular crash won't happen again.

Thanks,

=46elipe Damasio
