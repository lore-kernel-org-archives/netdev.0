From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Tue, 20 Apr 2010 17:39:22 +0200
Message-ID: <1271777962.7895.25.camel@edumazet-laptop>
References: <1271452358.16881.4486.camel@edumazet-laptop>
	 <1271520633.16881.4754.camel@edumazet-laptop>
	 <20100419.130905.210660275.davem@davemloft.net>
	 <20100419.132318.192086187.davem@davemloft.net>
	 <1271709121.3845.94.camel@edumazet-laptop>
	 <y2u412e6f7f1004191638mee9206dfoab7482bbff83e38d@mail.gmail.com>
	 <1271743164.3845.128.camel@edumazet-laptop>
	 <t2y65634d661004200804r15427f19k9d58862f05df94aa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:64665 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923Ab0DTPjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 11:39:31 -0400
Received: by bwz19 with SMTP id 19so96619bwz.21
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 08:39:30 -0700 (PDT)
In-Reply-To: <t2y65634d661004200804r15427f19k9d58862f05df94aa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 avril 2010 =C3=A0 08:04 -0700, Tom Herbert a =C3=A9crit :

> Maybe for the purposes of RPS, but hash collisions could definitely b=
e
> an issue in RFS.  If two active connections hit the same rps_flow
> entry this may cause thrashing of those connections between CPUs.  I
> think your patch may increase the probability of this happening.
>=20

Good point.

I'll make a gathering of tcp tuples on a busy server over a day and try
to compute number of clashes we can get with and without the addr/port
swapping.


