From: Alejandro Riveira =?UTF-8?B?RmVybsOhbmRleg==?=
	<ariveira@gmail.com>
Subject: Re: Loopback and Nagle's algorithm
Date: Tue, 12 Apr 2011 11:42:10 +0200
Message-ID: <20110412114210.65f202cc@varda>
References: <1302575869.13492.1440076201@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Adam McLaurin" <lkml@irotas.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1302575869.13492.1440076201@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

El Mon, 11 Apr 2011 22:37:49 -0400
"Adam McLaurin" <lkml@irotas.net> escribi=C3=B3:

 Just CCing netdev

> I understand that disabling Nagle's algorithm via TCP_NODELAY will
> generally degrade throughput. However, in my scenario (150 byte
> messages, sending as fast as possible), the actual throughput penalty
> over the network is marginal (maybe 10% at most).
>=20
> However, when I disable Nagle's algorithm when connecting over loopba=
ck,
> the performance hit is *huge* - 10x reduction in throughput.
>=20
> The question is, why is disabling Nagle's algorithm on loopback so mu=
ch
> worse w.r.t. throughput? Is there anything I can do to reduce the
> incurred throughput penalty?
>=20
> Thanks,
> Adam
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
