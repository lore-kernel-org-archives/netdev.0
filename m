From: Nicola Padovano <nicola.padovano@gmail.com>
Subject: Re: problem with flowi structure
Date: Sat, 2 Oct 2010 10:08:56 +0200
Message-ID: <AANLkTinObV+176prSdCL0RoVx7a74quUM5H58xR2_WLG@mail.gmail.com>
References: <AANLkTi=bGsvMqnTSanA73FhDH_DashmXTcA1sddtj0P6@mail.gmail.com>
 <1284650768.3352.37.camel@edumazet-laptop> <AANLkTimo1AeBS3rpQj0KtZL15Ct-DGTQMBUsL8hrVNOL@mail.gmail.com>
 <1284652453.3352.38.camel@edumazet-laptop> <AANLkTi=Y7beG4vPDx5eNg-gTN1CVg_G=1+dWwi2Xd2-R@mail.gmail.com>
 <AANLkTim7TeMCG9RQyrrk8WS4+S_y1q06+8FG2-X=1cB-@mail.gmail.com>
 <AANLkTimpnqNSE21u=2qjb5VGJrn_3_--Bqp4veCNXMPE@mail.gmail.com>
 <1284714533.3391.53.camel@edumazet-laptop> <AANLkTi=r__RA=5UfNnhsKizDF6OFVYXcSe9KOPx1zW0u@mail.gmail.com>
 <1284741295.3391.100.camel@edumazet-laptop> <AANLkTi=t2=jqu3XCC-3LK7x1_icke168Bqt-kmds6eOt@mail.gmail.com>
 <1284745887.2235.7.camel@edumazet-laptop> <AANLkTinx_18cVq52tmC0-g0qLYXJ5c_u9aad_rz_p2ND@mail.gmail.com>
 <1284746879.2235.9.camel@edumazet-laptop> <AANLkTi=hXc_ijNgxW+Q6jkRP_T1zjyy2mvKAdTSgeh7w@mail.gmail.com>
 <alpine.LNX.2.01.1010020146440.26371@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	AIJAZ BAIG <aijazbaig1@gmail.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1010020146440.26371@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

i.e. like a wildcard?

On Sat, Oct 2, 2010 at 1:46 AM, Jan Engelhardt <jengelh@medozas.de> wro=
te:
>
> On Friday 2010-09-17 20:25, Nicola Padovano wrote:
>>
>>[CODE]
>>if (hooknumber =3D=3D NF_INET_LOCAL_IN) fl.nl_u.ip4_u.saddr =3D niph-=
>saddr;
>> =A0//niph is the pointer to ip header of the packet to send
>>if (hooknumber =3D=3D NF_INET_FORWARD) fl.nl_u.ip4_u.saddr =3D 0;
>>[/CODE]
>>
>>so, i don't understand why saddr =3D 0 when the hooknumber is NF_INET=
_FORWARD....
>>
>>this is the real problem.
>
> 0 is automatic address selection.
>



--=20
Nicola Padovano
e-mail: nicola.padovano@gmail.com
web: http://npadovano.altervista.org

"My only ambition is not be anything at all; it seems the most
sensible thing" (C. Bukowski)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
