From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 2/2] nf_nat: don't check if the tuple is unique when there
	isn't any other choice
Date: Sat, 31 Jul 2010 22:07:38 +0800
Message-ID: <AANLkTikMsV9A6+p0VVXs6rAoAwhijQgPoDk_A1Rqx6ow@mail.gmail.com>
References: <1280542939-14606-1-git-send-email-xiaosuo@gmail.com>
	<alpine.LSU.2.01.1007311603010.32289@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1007311603010.32289@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 31, 2010 at 10:03 PM, Jan Engelhardt <jengelh@medozas.de> w=
rote:
>
> On Saturday 2010-07-31 04:22, Changli Gao wrote:
>>+++ b/net/ipv4/netfilter/nf_nat_proto_common.c
>>@@ -81,9 +81,9 @@ void nf_nat_proto_unique_tuple(struct nf_conntrack_=
tuple *tuple,
>> =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 off =3D *rover;
>>
>>- =A0 =A0 =A0for (i =3D 0; i < range_size; i++, off++) {
>>+ =A0 =A0 =A0for (i =3D 0; 1; off++) {
>
> The 1 looks strange. It's more common to express this without
> a condition, as in (i =3D 0; ; ++off).
>
>

OK, Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
