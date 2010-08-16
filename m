From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [LOCKDEP BUG][2.6.36-rc1] xt_info_wrlock?
Date: Mon, 16 Aug 2010 21:35:52 +0200
Message-ID: <1281987352.2487.40.camel@edumazet-laptop>
References: <1281978469.3268.55.camel@gandalf.stny.rr.com>
	 <1281979893.2524.54.camel@edumazet-laptop>
	 <1281981301.3268.110.camel@gandalf.stny.rr.com>
	 <1281982566.3268.137.camel@gandalf.stny.rr.com>
	 <1281983814.1926.1763.camel@laptop>
	 <1281984528.2487.25.camel@edumazet-laptop>
	 <1281986177.1926.1858.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, Ingo Molnar <mingo@elte.hu>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63222 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756356Ab0HPTf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 15:35:59 -0400
In-Reply-To: <1281986177.1926.1858.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 16 ao=C3=BBt 2010 =C3=A0 21:16 +0200, Peter Zijlstra a =C3=A9c=
rit :

> Adding lockdep_off() is just plain wrong, if you cannot describe the
> locking there's a fair chance its wrong anyway.
>=20

I see.

I described the fine locking after Steven comment, adding a long
Changelog.

http://patchwork.ozlabs.org/patch/61827/

If someone thinks this locking is buggy, please speak now ;)



