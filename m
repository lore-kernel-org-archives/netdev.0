From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] tcp: tcp_sendmsg() page recycling
Date: Sun, 04 Dec 2011 10:54:00 -0800
Message-ID: <1323024840.1785.10.camel@joe2Laptop>
References: <1323018317.2762.143.camel@edumazet-laptop>
	 <1323019253.1785.7.camel@joe2Laptop> <4EDBBB86.8050406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:58481 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753158Ab1LDSyB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Dec 2011 13:54:01 -0500
In-Reply-To: <4EDBBB86.8050406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-12-04 at 19:27 +0100, Nicolas de Peslo=C3=BCan wrote:
> Well, those two fragments don't look equivalent to the original one, =
unless TCP_OFF(sk) happens to=20
> be 0 before the test. But if this is true, then the whole thing seems=
 useless. Do I miss something?

Nope, you're completely correct.  It's just me not typing correctly.
