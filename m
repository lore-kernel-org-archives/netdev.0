From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: v3.8.5: "TCP: snd_cwnd is nul, please report this bug."
Date: Sun, 02 Jun 2013 07:22:36 -0700
Message-ID: <1370182956.24311.34.camel@edumazet-glaptop>
References: <87zjx9pf13.fsf@nemi.mork.no>
	 <1365431422.3887.10.camel@edumazet-glaptop> <87li8tyrzs.fsf@nemi.mork.no>
	 <1365434301.3887.14.camel@edumazet-glaptop> <87k3mcizlm.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:59429 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711Ab3FBOWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 10:22:38 -0400
Received: by mail-pb0-f42.google.com with SMTP id uo1so4537768pbc.15
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 07:22:38 -0700 (PDT)
In-Reply-To: <87k3mcizlm.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-02 at 12:19 +0200, Bj=C3=B8rn Mork wrote:

> Just FYI, in case you wondered what happened here...
>=20
> I've been running with the debug patch since you sent it to me, and
> still is.  But the warning has not yet reappeared.
>=20
> I'll continue using the patch for a while, but will eventually drop i=
t
> if the warning cannot be reproduced in another couple of weeks time.
> There have been a few fixes to iwlwifi in the meantime, and I do not
> rule out the possibility that some of these removed the triggering
> event.
>=20

What exact tree are you running ?

=46-RTO code was replaced by Yuching Cheng, and it might very well have
solved these issues.

commit e33099f96d99c391b3325caa9c44258de04aae86=20
("tcp: implement RFC5682 F-RTO")

commit ab42d9ee3d215ab74a49818ffc53771a88ce7ddf
("tcp: refactor CA_Loss state processing")

commit 9b44190dc114c1720b34975b5bfc65aece112ced
("tcp: refactor F-RTO")

Thanks
