From: Pascal Hambourg <pascal.mail@plouf.fr.eu.org>
Subject: Re: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Thu, 25 Mar 2010 09:38:57 +0100
Message-ID: <4BAB2121.2030503@plouf.fr.eu.org>
References: <4B88BE30.80206@cn.fujitsu.com> <4B97D34C.4020509@gmail.com> <4B98B4FC.50904@cn.fujitsu.com> <4B9B9766.3090200@linux-ipv6.org> <4B9E5FEC.9010002@trash.net> <4BA8EC4A.9070802@linux-ipv6.org> <4BA8F75E.2040303@trash.net> <4BA90F72.6010404@linux-ipv6.org> <alpine.DEB.2.00.1003232050540.18241@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Shan Wei <shanwei@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1003232050540.18241@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Jozsef Kadlecsik a =E9crit :
>=20
> On Wed, 24 Mar 2010, YOSHIFUJI Hideaki wrote:
>=20
>>> In this case without conntrack, IPv6 would send an ICMPv6 message,
>>> so in my opinion the transparent thing to do would be to still send
>>> them. Of course only if reassembly is done on an end host.
>> Well, no.  conntrack should just forward even uncompleted fragments
>> to next process (e.g. core ipv6 code), and then the core would send
>> ICMP error back.  ICMP should be sent by the core ipv6 code accordin=
g
>> to decision of itself, not according to netfilter.
>=20
> But what state could be associated by conntrack to the uncompleted=20
> fragments but the INVALID state? In consequence, in any sane setup, t=
he=20
> uncompleted fragments will be dropped silently by a filter table rule
> and no ICMP error message will be sent back.

AFAIK, in the IPv4 stack the reassembly takes place before the INPUT
chains (NF_IP_LOCAL_IN hook). Is it different in the IPv6 stack ?
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
