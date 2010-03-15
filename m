From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Mon, 15 Mar 2010 17:27:24 +0100
Message-ID: <4B9E5FEC.9010002@trash.net>
References: <4B88BE30.80206@cn.fujitsu.com> <4B97D34C.4020509@gmail.com> <4B98B4FC.50904@cn.fujitsu.com> <4B9B9766.3090200@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shan Wei <shanwei@cn.fujitsu.com>,
	YOSHIFUJI Hideaki <hideaki.yoshifuji@gmail.com>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B9B9766.3090200@linux-ipv6.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki wrote:
> (2010/03/11 18:16), Shan Wei wrote:
>>> On the other hand, I'd even say we should NOT send
>>> icmp here (at least by default) because standard routers
>>> never send such packet.
>>
>> Yes=EF=BC=8Cfor routers, the patch-set does not send icmp message to
>> source host. It only does on destination host with IPv6 connection
>> track enable.
>=20
> Please make it optional (via parameter) at least.

The ICMP messages are only sent if the packet is destined for the
local host, similar to what IPv6 defrag would do if conntrack wouldn't
be used. So this patch increases consistency, why should we make this
optional?
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
