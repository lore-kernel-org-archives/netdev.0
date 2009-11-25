From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [tproxy] [HELP] Tproxy server Can't receive any client packet
Date: Wed, 25 Nov 2009 09:30:40 +0100
Message-ID: <1259137840.9191.7.camel@nienna.balabit>
References: <d5cf4b4f0911222251u1589c66ar78810d5b9d87cb5e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tproxy@lists.balabit.hu, netfilter-announce@lists.netfilter.org,
	netfilter@lists.netfilter.org, netdev@vger.kernel.org,
	rnd@elim.net, dylee@elim.net
To: =?UTF-8?Q?=EB=B0=95=EC=A0=9C=ED=98=B8?= <linuxpark@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:42990 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933602AbZKYIzE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2009 03:55:04 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 7D64F13A1B4
	for <netdev@vger.kernel.org>; Wed, 25 Nov 2009 09:30:41 +0100 (CET)
In-Reply-To: <d5cf4b4f0911222251u1589c66ar78810d5b9d87cb5e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 2009-11-23 at 15:51 +0900, =EB=B0=95=EC=A0=9C=ED=98=B8 wrote:
> i have a problem in my transparent proxy test,
> i recently made up the testbed as below to run the tproxy patched
> apache proxy [mod_proxy],
> and i applied all iptables and routing rules with referencing the
> readme file [http://www.balabit.com/downloads/files/tproxy/README.txt=
,
> http://www.mjmwired.net/kernel/Documentation/networking/tproxy.txt]
> the proxy server listening the port 3128 and i checked there were no =
problem.
> but  when the client tried to connect the web server,
> the packets reached to the box and i found the usage counts of filter
> rules in the mangle table incresed
> but my tproxy server could not receive any corresponding packet from =
the socket
>=20
> I want to know why my proxy server can't receive any packet through t=
he socket,
> Do i need some more DNAT rules ?

Would you mind testing the setup with an unpatched upstream kernel, tha=
t
has tproxy built-in? (2.6.31, for example)

Also, please download the latest iptables from netfilter.org and try
using that. (No need for patching, tproxy support is in upstream.)

That would help a lot in identifying the source of the issue. Thanks in
advance.

Cheers,
Krisztian

