From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 16:54:29 +0100
Message-ID: <1447948469.2030778.444426889.4F4A5648@webmail.messagingengine.com>
References: <CAKD1Yr0Gpr6Ex2i1TXEWyETn48P4g5vBvFZ9=_g+Lz_7-PqBDQ@mail.gmail.com>
 <20151118.153508.123902005995190872.davem@davemloft.net>
 <1447879416.562854.443622857.62708268@webmail.messagingengine.com>
 <20151118.224919.452852815199526735.davem@davemloft.net>
 <CALx6S36-tBwAGFFpdrhXjAXvNmxUXsbRV17Wayjr6-hsKsCeNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	=?UTF-8?Q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:50154 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934018AbbKSPyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 10:54:33 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 34A782075E
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 10:54:30 -0500 (EST)
In-Reply-To: <CALx6S36-tBwAGFFpdrhXjAXvNmxUXsbRV17Wayjr6-hsKsCeNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015, at 06:12, Tom Herbert wrote:
> I think this solution presumes some out of band signaling about a path
> failure deep in the network that is not reported via the TCP
> connection. This solution is obviously only as good as the signaling,
> but clearly the most general solution to maintaining reachability has
> been (and unfortunately will probably continue to be) application
> keepalives.

Ack. With emphasis of *application*. :)
