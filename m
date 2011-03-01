From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Tue, 01 Mar 2011 06:01:23 +0100
Message-ID: <1298955683.2676.2.camel@edumazet-laptop>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
	 <alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
	 <1298793252.8726.45.camel@edumazet-laptop>
	 <AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
	 <20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
	 <1298837273.8726.128.camel@edumazet-laptop>
	 <20110228161115.GB2515@tuxdriver.com>
	 <1298911694.2941.639.camel@edumazet-laptop>
	 <20110228165501.GC2515@tuxdriver.com>
	 <AANLkTinj5szpStmA+fZ1xggdyTS+sd8Y9jXaYquDNEjs@mail.gmail.com>
	 <AANLkTinFZu5AgfhO6PoA7C1NTGSfD8HH0KXq_o-mHEJF@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Heffner <johnwheffner@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Mikael Abrahamsson <swmike@swm.pp.se>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Albert Cahalan <acahalan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinFZu5AgfhO6PoA7C1NTGSfD8HH0KXq_o-mHEJF@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 23:11 -0500, Albert Cahalan a =C3=A9=
crit :

> It sounds like you need a callback or similar, so that TCP can be
> informed later that the drop has occurred.

There is the thing called skb destructor / skb_orphan() mess, that is
not stackable... Might extend this to something more clever, and be abl=
e
to call functions (into TCP stack for example) giving a status of skb :
Sent, or dropped somewhere in the stack...
