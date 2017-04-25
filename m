From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: Re: [PATCH v1] net: phy: fix auto-negotiation stall due to unavailable interrupt
Date: Tue, 25 Apr 2017 18:25:30 +0300
Message-ID: <B99ADC0E-A793-4334-A086-9F2CE045AB7E@gmail.com>
References: <1492686004-30527-1-git-send-email-al.kochet@gmail.com> <1492686004-30527-2-git-send-email-al.kochet@gmail.com> <20170425.103644.75674234677063517.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Roger Quadros <rogerq@ti.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:34935 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1949932AbdDYPZe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:25:34 -0400
In-Reply-To: <20170425.103644.75674234677063517.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David!

> 25 =D0=B0=D0=BF=D1=80. 2017 =D0=B3., =D0=B2 17:36, David Miller =
<davem@davemloft.net> =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB(=D0=B0):
>=20
> So... what are we doing here?
>=20
> My understanding is that this should fix the same problem that commit
> 99f81afc139c6edd14d77a91ee91685a414a1c66 ("phy: micrel: Disable auto
> negotiation on startup") fixed and that this micrel commit should thus
> be reverted to improve MAC startup times which regressed.
>=20
> Florian, any guidance?

Yes, this should be done.

I aksed Alexandre to check if 99f81afc139c6edd14d77a91ee91685a414a1c66 =
("phy: micrel: Disable auto
negotiation on startup=C2=BB) can be reverted, and he answered what it =
may do that
sometime this/next week.

Alexander.
