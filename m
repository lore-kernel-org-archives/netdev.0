From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 04/12] l2tp: Add ppp device name to L2TP ppp session
 data
Date: Thu, 01 Apr 2010 09:30:34 +0200
Message-ID: <1270107034.2229.5.camel@edumazet-laptop>
References: <20100330161725.9628.69994.stgit@bert.katalix.com>
	 <20100330161746.9628.40723.stgit@bert.katalix.com>
	 <20100330092914.4f3e9ed3@nehalam>	<4BB2FD0D.1080105@katalix.com>
	 <20100331160811.16351eb7@s6510>  <4BB4490F.8090406@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:41451 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929Ab0DAHak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 03:30:40 -0400
Received: by bwz25 with SMTP id 25so616928bwz.28
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 00:30:38 -0700 (PDT)
In-Reply-To: <4BB4490F.8090406@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 avril 2010 =C3=A0 08:19 +0100, James Chapman a =C3=A9crit :

> There might be thousands of L2TP sessions in some setups. Populating
> sysfs with a link for each of those sessions isn't practical. The
> existing /proc file dumps its info as a single text file for this
> reason. I'd also like to provide the device name in the session netli=
nk
> message, which is the interface used by l2tp userspace, so I need a
> kernel API to retrieve the device name from ppp.
>=20
> I like the suggestion of using debugfs for access to driver debug inf=
o
> though. I propose leaving the /proc file for L2TPv2 only, removing th=
e
> L2TPv3 data that I added to the proc file in this patch series, to
> retain compatibility with the existing driver. This would show only
> L2TPv2 sessions and tunnels. For new driver functionality (L2TPv3 etc=
),
> use debugfs. The debugfs files would dump lists in a similar form to =
the
> current code, listing all tunnels (L2TPv2 and L2TPv3) in a single fil=
e.
> Using debugfs gives more flexibility for adding additional info later=
,
> as required. How does that sound?
>=20

debugfs ? I dont get it, sorry.

Why not using netlink, as most iproute2 utilities do ?


