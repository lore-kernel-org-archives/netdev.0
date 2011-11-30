From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC PATCH 00/18] netfilter: IPv6 NAT
Date: Wed, 30 Nov 2011 11:07:17 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1111301004440.18890@frira.zrqbmnf.qr>
References: <CAF9AA63.1622%ulrich.weber@sophos.com> <a2407c3b6405bd682cedad6db82cf225@treenet.co.nz> <4ED4A399.6090709@sophos.com> <alpine.LNX.2.01.1111291255200.20965@frira.zrqbmnf.qr> <4ED550E7.1090609@ans.pl> <alpine.LNX.2.01.1111292306460.18953@frira.zrqbmnf.qr>
 <4ED57724.4010204@ans.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Weber <ulrich.weber@sophos.com>,
	Amos Jeffries <squid3@treenet.co.nz>,
	"sclark46@earthlink.net" <sclark46@earthlink.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?Q?Krzysztof_Ol=C4=99dzki?= <ole@ans.pl>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4ED57724.4010204@ans.pl>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2011-11-30 01:21, Krzysztof Ol=C4=99dzki wrote:
>>>
>>>>>However with NAT you could get some kind of anonymity.
>>>
>>>But without NAT you have pretty big chance to have the same IPv6=20
>>>*suffix* everywhere, based on you MAC address. without NAT you have=20
>>>pretty big chance to have the same IPv6 *suffix* everywhere, based o=
n=20
>>>you MAC address.
>>
>>Same suffix? Certainly not with [PrivExt...]
>
>What if:
>
>1. You or your users don't have modern OS on your device so there is n=
o=20
>DHCPv6 or rfc3041/4941 support?

Dedicated separate program (that's what you would probably do on
Windows XP which lacks DHCPv6, PrivExt and also does not even allow
manually setting an address via GUI).

>3. You need to have static addresses in your network for access contro=
l?

Access control can be done based on MAC within a broadcast domain so
you don't have to eschew Privacy Extensions if you can do so.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
