From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Fri, 15 Aug 2008 01:34:07 -0300
Message-ID: <20080815013407.4a594288@tux>
References: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
	<20080811.144421.234396007.davem@davemloft.net>
	<200808120946.19459.thomas.jarosch@intra2net.com>
	<20080812.011822.155249871.davem@davemloft.net>
	<20080812144309.7d62fd86@tux>
	<Pine.LNX.4.64.0808122044450.16105@wrl-59.cs.helsinki.fi>
	<20080813145310.0c1e534c@tux>
	<Pine.LNX.4.64.0808132108480.18807@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>, sr@securenet.de,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:56027 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbYHOEeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 00:34:13 -0400
Received: by yx-out-2324.google.com with SMTP id 8so585247yxm.1
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 21:34:12 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0808132108480.18807@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Aug 2008 21:34:10 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Ok, thanks for your efforts... These are often hard to reproduce beca=
use
> some not that likely pattern needs to happen and such things is often=
 not
> easily controllable (if it is at all possible to influence the=20
> likelyhoods).

	Hi Ilpo, I don't know if the dumps are correct, but I did when
the connection was stalled. The problem is, when I dumped "eth0", the
connection suddenly come back alive again... so, I don't know if it's
useless or not:

	For tun1 interface (which I use for my vpn):

http://www.abusar.org/dump-tun1.log

	local loopback interface:

http://www.abusar.org/dump-lo.log

	eth0, if it matters:

http://www.abusar.org/dump-eth0.log

	Thanks.



--=20
