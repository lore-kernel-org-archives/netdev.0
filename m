From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Fri, 23 Apr 2010 13:06:06 +0200
Message-ID: <1272020766.7895.7975.camel@edumazet-laptop>
References: <1271941082.14501.189.camel@jdb-workstation>
	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
	 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>
	 <1271948029.7895.5707.camel@edumazet-laptop>
	 <20100422155123.GA2524@linux.vnet.ibm.com>
	 <1271952128.7895.5851.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
	 <1271970199.7895.6482.camel@edumazet-laptop>
	 <1271970893.7895.6507.camel@edumazet-laptop>  <4BD1784A.6010306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, paulmck@linux.vnet.ibm.com,
	Changli Gao <xiaosuo@gmail.com>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BD1784A.6010306@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 23 avril 2010 =C3=A0 12:36 +0200, Patrick McHardy a =C3=A9c=
rit :
> Eric Dumazet wrote:
> > Le jeudi 22 avril 2010 =C3=A0 23:03 +0200, Eric Dumazet a =C3=A9cri=
t :
> >>> Guess I have to reproduce the DoS attack in a testlab (I will fir=
st have=20
> >>> time Tuesday).  So we can determine if its bad hashing or restart=
 of the=20
> >>> search loop.
> >>>
> >=20
> > Or very long chains, if attacker managed to find a jhash flaw.
>=20
> That should be visible in the "searched" statistic.
>=20
> > You could add a lookup_restart counter :
>=20
> I've applied Jespers equivalent patch.

Yes of course, I missed it or I would not have cooked it ;)

Thanks


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
