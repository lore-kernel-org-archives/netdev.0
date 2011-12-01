From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: [RFC PATCH 00/18] netfilter: IPv6 NAT
Date: Thu, 01 Dec 2011 08:01:54 +0100
Message-ID: <4ED72662.6080800@ans.pl>
References: <CAF9AA63.1622%ulrich.weber@sophos.com> <a2407c3b6405bd682cedad6db82cf225@treenet.co.nz> <4ED4A399.6090709@sophos.com> <alpine.LNX.2.01.1111291255200.20965@frira.zrqbmnf.qr> <4ED550E7.1090609@ans.pl> <alpine.LNX.2.01.1111292306460.18953@frira.zrqbmnf.qr> <4ED57724.4010204@ans.pl> <alpine.LNX.2.01.1111301004440.18890@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Weber <ulrich.weber@sophos.com>,
	Amos Jeffries <squid3@treenet.co.nz>,
	"sclark46@earthlink.net" <sclark46@earthlink.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1111301004440.18890@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2011-11-30 11:07, Jan Engelhardt wrote:
>
> On Wednesday 2011-11-30 01:21, Krzysztof Ol=C4=99dzki wrote:
>>>>
>>>>>> However with NAT you could get some kind of anonymity.
>>>>
>>>> But without NAT you have pretty big chance to have the same IPv6
>>>> *suffix* everywhere, based on you MAC address. without NAT you hav=
e
>>>> pretty big chance to have the same IPv6 *suffix* everywhere, based=
 on
>>>> you MAC address.
>>>
>>> Same suffix? Certainly not with [PrivExt...]
>>
>> What if:
>>
>> 1. You or your users don't have modern OS on your device so there is=
 no
>> DHCPv6 or rfc3041/4941 support?
>
> Dedicated separate program (that's what you would probably do on
> Windows XP which lacks DHCPv6, PrivExt and also does not even allow
> manually setting an address via GUI).

Too much effort. Really.

>> 3. You need to have static addresses in your network for access cont=
rol?
>
> Access control can be done based on MAC within a broadcast domain so
> you don't have to eschew Privacy Extensions if you can do so.

Maybe if you have a very small network - just one or two subnets, one=20
router... Again - maybe. It is definitely not going to work on a large,=
=20
multisite network with many intermediate routers.

All you can do on edge devices is checking client's MAC, requring 802.1=
X=20
and making sure that IP matches MAC (and possibly DHCP lease) and=20
similar things.

Best regards,

				Krzysztof Ol=C4=99dzki
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
