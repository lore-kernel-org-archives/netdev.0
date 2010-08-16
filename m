From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [LOCKDEP BUG][2.6.36-rc1] xt_info_wrlock?
Date: Mon, 16 Aug 2010 20:48:48 +0200
Message-ID: <1281984528.2487.25.camel@edumazet-laptop>
References: <1281978469.3268.55.camel@gandalf.stny.rr.com>
	 <1281979893.2524.54.camel@edumazet-laptop>
	 <1281981301.3268.110.camel@gandalf.stny.rr.com>
	 <1281982566.3268.137.camel@gandalf.stny.rr.com>
	 <1281983814.1926.1763.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, Ingo Molnar <mingo@elte.hu>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64269 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845Ab0HPSsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 14:48:53 -0400
In-Reply-To: <1281983814.1926.1763.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 16 ao=C3=BBt 2010 =C3=A0 20:36 +0200, Peter Zijlstra a =C3=A9c=
rit :
> On Mon, 2010-08-16 at 14:16 -0400, Steven Rostedt wrote:
> > @@ -729,8 +729,10 @@  static void get_counters(const struct
> > xt_table_info *t,
> >         local_bh_enable();
> >         /* Processing counters from other cpus, we can let bottom h=
alf
> > enabled,
> >          * (preemption is disabled)
> > +        * We must turn off lockdep to avoid a false positive.
> >          */
> > =20
> > +       lockdep_off();
> >         for_each_possible_cpu(cpu) {
> >=20
> nack!


Interesting.

Care to elaborate ?



