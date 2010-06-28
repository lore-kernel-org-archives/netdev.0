From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: [PATCH net-next-2.6] ipv4: sysctl to block responding on down interface
Date: Mon, 28 Jun 2010 14:28:29 -0700
Message-ID: <D1C84781-4EC6-42D0-AE3E-258BE8BAA4BC@earthlink.net>
References: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se>	 <20100611084854.0680c014@nehalam> <OF62B30BCC.F8523B86-ONC1257750.00687496-C1257750.0068AA27@transmode.se> <1277754121.4235.673.camel@edumazet-laptop> <OF0640B724.BFF8DEB7-ONC1257750.00728ECF-C1257750.00742EFA@transmode.se>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:45446 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751510Ab0F1V2m convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 17:28:42 -0400
In-Reply-To: <OF0640B724.BFF8DEB7-ONC1257750.00728ECF-C1257750.00742EFA@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 28, 2010, at 2:09 PM, Joakim Tjernlund wrote:

> Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/06/28 21:42:01:
>>=20
>> Le lundi 28 juin 2010 =E0 21:03 +0200, Joakim Tjernlund a =E9crit :
>>> Stephen Hemminger <shemminger@vyatta.com> wrote on 2010/06/11 17:48=
:54:
>>>>=20
>>>> When Linux is used as a router, it is undesirable for the kernel t=
o process
>>>> incoming packets when the address assigned to the interface is dow=
n.
>>>> The initial problem report was for a management application that u=
sed ICMP
>>>> to check link availability.
>>>>=20
>>>> The default is disabled to maintain compatibility with previous be=
havior.
>>>> This is not recommended for server systems because it makes fail o=
ver more
>>>> difficult, and does not account for configurations where multiple =
interfaces
>>>> have the same IP address.
>>>>=20
>>>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>>=20
>>> Ping David et. all?
>>> I too want this.
>>=20
>> You probably missed David reply
>>=20
>> http://permalink.gmane.org/gmane.linux.network/164494
>=20
> Sure did, don't know how that happened, sorry.
>=20
> Reading David's reply I do wonder about the current behaviour. Why
> is it so important to keep responding to an IP address when the
> admin has put the interface holding that IP address into administrati=
vely
> down state? I don't think the weak host model stipulates that it must=
 be so, does it?
>=20
> To me it "ifconfig eth0 down" means not only to stop using the I/F bu=
t
> also any IP address associated with the I/F. I was rather surprised t=
hat
> it didn't work that way. I don't see any way to make Linux stop respo=
nding to
> that IP other that removing it completely from the system, which is r=
ather
> awkward.
>=20
> Note, I don't mean that the same should be applied for the No Carrier=
 case, just
> ifconfig down.
>=20
> Jocke
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hey guys, isn't the support of magic pkts/ Energy star require the rece=
ipt
of pkts while the intf is down?

Mitchell Erblich