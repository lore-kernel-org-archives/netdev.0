From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [PATCHv6 0/3] Interface group patches
Date: Tue, 20 Nov 2007 14:52:12 +0100
Message-ID: <4742E68C.2000802@balabit.hu>
References: <11955644701165-git-send-email-panther@balabit.hu> <Pine.LNX.4.64.0711201425530.32378@fbirervta.pbzchgretzou.qr>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0711201425530.32378@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt =EDrta:
> On Nov 20 2007 14:14, Laszlo Attila Toth wrote:
>> This is the 6th version of our interface group patches.
>>
>> The interface group value can be used to manage different interfaces
>> at the same time such as in netfilter/iptables.
>=20
> I take it you could not use...?
> 	iptables -i iif1 -j dosomething
> 	iptables -i iif2 -j dosomething

This kind of usage requires static interface names. But there are=20
dynamic interfaces such as ppp, where the actual name is not always=20
known or sometimes they exist sometimes not. It is difficult to use=20
iptables this way, and every ifup/ifdown requires change in the iptable=
s=20
ruleset (donwload it, modify and upload to the kernel). It may be too s=
low.

>=20
>> The netfilter patch
>> is ready but future plan is the same for ip/tc commands (except
>> the ifgroup value change which happens via "ip link set" command).
>=20
> How can it be useful in conjunction with tc?

jamal wrote it previously:
http://marc.info/?l=3Dlinux-netdev&m=3D119253403415810&w=3D2

--=20
Attila
-
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
