From: Nicola Padovano <nicola.padovano@gmail.com>
Subject: Re: problem with flowi structure
Date: Fri, 17 Sep 2010 19:05:14 +0200
Message-ID: <AANLkTi=t2=jqu3XCC-3LK7x1_icke168Bqt-kmds6eOt@mail.gmail.com>
References: <AANLkTi=bGsvMqnTSanA73FhDH_DashmXTcA1sddtj0P6@mail.gmail.com>
 <1284650768.3352.37.camel@edumazet-laptop> <AANLkTimo1AeBS3rpQj0KtZL15Ct-DGTQMBUsL8hrVNOL@mail.gmail.com>
 <1284652453.3352.38.camel@edumazet-laptop> <AANLkTi=Y7beG4vPDx5eNg-gTN1CVg_G=1+dWwi2Xd2-R@mail.gmail.com>
 <AANLkTim7TeMCG9RQyrrk8WS4+S_y1q06+8FG2-X=1cB-@mail.gmail.com>
 <AANLkTimpnqNSE21u=2qjb5VGJrn_3_--Bqp4veCNXMPE@mail.gmail.com>
 <1284714533.3391.53.camel@edumazet-laptop> <AANLkTi=r__RA=5UfNnhsKizDF6OFVYXcSe9KOPx1zW0u@mail.gmail.com>
 <1284741295.3391.100.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: AIJAZ BAIG <aijazbaig1@gmail.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1284741295.3391.100.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ok man :)
the last question is about  fl.nl_u.ip4_u.saddr =3D 0...
is it a kind of "jolly" selector of the source address?
i.e. if we have a simplified cache route

SOURCE IP    DEST IP    NEXT HOP
ips1                  google         nexthop1
ips2                  google         nexthop2

with
=2E..saddr =3D 0
=2E...daddr =3D google
=2E...tos =3D....
i get nexthop1 or nexthop2. right?


On Fri, Sep 17, 2010 at 6:34 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 17 septembre 2010 =E0 18:27 +0200, Nicola Padovano a =E9c=
rit :
>> > With different keys (src addr, tos, fwmark, ...) we can have a lot=
 of
>> > different routes for apparently same destination
>> and why this reasoning it isn't present on the routing table?
>> I mean: there will be a reason for which this isn't present in the r=
outing table
>>
>>
>
> It is present, of course, since route cache can be flushed (or
> bypassed), you need to be able to rebuild it from a stable reference.
>
> ip rule ls
>
> ip ro list table xxx
>
>
>
>



--=20
Nicola Padovano
e-mail: nicola.padovano@gmail.com
web: http://npadovano.altervista.org
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
