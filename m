From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: IP_NODEFRAG option for IPv4 socket
Date: Tue, 15 Jun 2010 11:49:33 +0200
Message-ID: <1276595373.2541.58.camel@edumazet-laptop>
References: <4C0FA24A.7060907@trash.net>
	 <20100610065631.GA1915@jolsa.lab.eng.brq.redhat.com>
	 <4C10ACDC.6010108@trash.net>
	 <20100610095312.GC1915@jolsa.lab.eng.brq.redhat.com>
	 <4C10B8C8.2050201@trash.net> <20100611081604.GA1739@jolsa.Belkin>
	 <alpine.LSU.2.01.1006111152230.30433@obet.zrqbmnf.qr>
	 <20100611131038.GB1739@jolsa.Belkin> <20100615065335.GA8840@jolsa.Belkin>
	 <1276586029.2541.12.camel@edumazet-laptop>
	 <20100615091715.GB8840@jolsa.Belkin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100615091715.GB8840@jolsa.Belkin>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 15 juin 2010 =C3=A0 11:18 +0200, Jiri Olsa a =C3=A9crit :

> > Hmm... what about cloning ?
>=20
> I think as this is the property of the socket (not skb),
> it has no affect for cloning
>=20

Sorry, I was thinking of sk_clone(). I sometime forgets sock_copy() cop=
y
all fields.

This is a non issue for raw sockets, if IP_NODEFRAG is limited to RAW
sockets now and in the future.





--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
