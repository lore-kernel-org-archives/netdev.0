From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Mon, 15 Nov 2010 12:31:12 +0100
Message-ID: <1289820672.2607.10.camel@edumazet-laptop>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
	 <1289489007.17691.1310.camel@edumazet-laptop>
	 <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
	 <ZXmP8hjgLHA.4648@exchange1.tad.internal.tilera.com>
	 <4CDF1945.8090101@tilera.com>
	 <AANLkTind92uwcigzmDn8yn9a22exDy7zcreGQ5-6NLV-@mail.gmail.com>
	 <AANLkTinzRm_5WW5HwxzXqZZD4255GDpR4yzELqz66Dfn@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Metcalf <cmetcalf@tilera.com>,
	=?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Cypher Wu <cypher.w@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinzRm_5WW5HwxzXqZZD4255GDpR4yzELqz66Dfn@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 15 novembre 2010 =C3=A0 19:18 +0800, Cypher Wu a =C3=A9crit :
> In that post I want to confirm another thing: if we join/leave on
> different cores that every call will start the timer for IGMP message
> using the same in_dev->mc_list, could that be optimized?
>=20

Which timer exactly ? Is it a real scalability problem ?

I believe RTNL would be the blocking point actually...
