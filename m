From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 v3] net_sched: SFB flow scheduler
Date: Wed, 23 Feb 2011 17:13:20 +0100
Message-ID: <1298477600.3301.367.camel@edumazet-laptop>
References: <20110221160306.GA9650@tuxdriver.com>
	 <1298308283.2849.5.camel@edumazet-laptop>
	 <1298390536.2861.9.camel@edumazet-laptop>
	 <1298474091.3301.364.camel@edumazet-laptop>
	 <20110223074305.755c5713@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>,
	"John W. Linville" <linville@tuxdriver.com>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f51.google.com ([209.85.214.51]:62491 "EHLO
	mail-bw0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920Ab1BWQN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 11:13:26 -0500
Received: by bwz10 with SMTP id 10so270283bwz.10
        for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 08:13:25 -0800 (PST)
In-Reply-To: <20110223074305.755c5713@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 23 f=C3=A9vrier 2011 =C3=A0 07:43 -0800, Stephen Hemminger =
a =C3=A9crit :
> On Wed, 23 Feb 2011 16:14:51 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > 1) SFB default child qdisc is pfifo_fast. It can be changed by anot=
her
> > qdisc but a child qdisc MUST not drop a packet previously queued. T=
his
> > is because SFB needs to handle a dequeued packet in order to mainta=
in
> > its virtual queue states. pfifo_head_drop or CHOKe should not be us=
ed.
>=20
> Why not add a flag field to Qdisc_ops and to mark qdisc's that
> are (or not) work conserving?
>=20

That was my initial idea, but have no idea how to implement it (outside
of fast path, I mean...)



