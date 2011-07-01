From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/2] nfnetlink: add RCU in nfnetlink_rcv_msg()
Date: Fri, 1 Jul 2011 16:11:25 +0200
Message-ID: <20110701141125.GS16021@Chamillionaire.breakpoint.cc>
References: <1309433652.1994.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <4E0C651A.1000300@trash.net>
 <1309446900.1994.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <4E0C8902.8070303@earthlink.net>
 <4E0C8D7F.3000902@trash.net>
 <1309453730.5846.31.camel@tiger.regit.org>
 <1309455919.2515.3.camel@edumazet-laptop>
 <1309503610.2515.18.camel@edumazet-laptop>
 <20110701074936.GR16021@Chamillionaire.breakpoint.cc>
 <1309534078.2599.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Westphal <fw@strlen.de>, Patrick McHardy <kaber@trash.net>,
	Eric Leblond <eric@regit.org>, sclark46@earthlink.net,
	Kuzin Andrey <kuzinandrey@yandex.ru>,
	Anders Nilsson Plymoth <lanilsson@gmail.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1309534078.2599.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Le vendredi 01 juillet 2011 =E0 09:49 +0200, Florian Westphal a =E9cr=
it :
> > But I guess even having to grab a refcount would be
> > a huge win as opposed to holding on to the nfnl mutex...
> >=20
> > We'd also need to audit all ->call implementations; most
> > of them assume the nfnl_mutex is being hold.
>=20
> We can do another way : Introduce a new ->call_rcu() implementation
> and convert places where we prefer not holding nfnf_mutex.
> If/when all places are converted, remove the ->call() field for good.

Sounds reasonable to me.

Both patches look great, thanks a lot for doing this Eric!
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
