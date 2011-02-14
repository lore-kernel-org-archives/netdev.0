From: Patrick McHardy <kaber@trash.net>
Subject: Re: Possible netfilter-related memory corruption in 2.6.37
Date: Mon, 14 Feb 2011 17:37:28 +0100
Message-ID: <4D595A48.9070201@trash.net>
References: <4D594313.4050009@redhat.com>	 <1297696283.2996.33.camel@edumazet-laptop>	 <alpine.LNX.2.01.1102141617330.12050@obet.zrqbmnf.qr>	 <1297698641.2996.38.camel@edumazet-laptop>  <4D595745.7070505@trash.net> <1297700955.2996.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>, Avi Kivity <avi@redhat.com>,
	netfilter-devel@vger.kernel.org,
	Marcelo Tosatti <mtosatti@redhat.com>,
	nicolas prochazka <prochazka.nicolas@gmail.com>,
	KVM list <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1297700955.2996.40.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 14.02.2011 17:29, schrieb Eric Dumazet:
> Le lundi 14 f=C3=A9vrier 2011 =C3=A0 17:24 +0100, Patrick McHardy a =C3=
=A9crit :
>>> Also, I wonder if RCU rules are respected in nf_iterate().
>>> For example this line is really suspicious :
>>>
>>> *i =3D (*i)->prev;
>>
>> Yeah, that definitely looks wrong. How about this instead?
>>
>=20
> This patch seems fine to me, thanks !
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

THanks Eric, I've queued the patch for 2.6.38.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
