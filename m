From: Amos Jeffries <squid3@treenet.co.nz>
Subject: Re: [RFC PATCH 00/18] netfilter: IPv6 NAT
Date: Tue, 29 Nov 2011 11:03:13 +1300
Message-ID: <a2407c3b6405bd682cedad6db82cf225@treenet.co.nz>
References: <CAF9AA63.1622%ulrich.weber@sophos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <sclark46@earthlink.net>, <kaber@trash.net>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Ulrich Weber <Ulrich.Weber@Sophos.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAF9AA63.1622%ulrich.weber@sophos.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 On Mon, 28 Nov 2011 20:25:48 +0000, Ulrich Weber wrote:
> Am 28.11.11 18:14 schrieb "Stephen Clark" unter:
>
>>Probabably a dumb question but are these patches for natting ipv6 to
>>ipv6 or ipv4 to ipv6?
>
> These patches are for natting IPv6 addresses behind whole IPv6=20
> subnets
> or just behind one IPv6 address.
>
> This is useful for multiple Internet uplinks, where you want full=20
> control
> on the router what connections are sent over which interface. Or its=20
> quite
> easy to setup Load Balancing rules or create a DMZ. There a lots of=20
> use
> cases=C5=A0

 I'm going to dare to call FUD on those statements...

  * Load Balancing - what is preventing your routing rules or packet=20
 marking using the same criteria as the NAT changer? nothing. Load=20
 balancing works perfectly fine without NAT.

  * outgoing packet control - packets will happily leave the "wrong"=20
 interface after NAT unless you add routing and firewall controls=20
 separate to NAT. Packet control works *better* without NAT erasing=20
 original IP information resulting in mistakenly NAT'ed packets go out=20
 the wrong interface.


 I have long been of the opinion that all NAT really offers is the=20
 ability to easily and cleanly multi-home several global public prefixe=
s=20
 from a unified PI space. This is a very important aspect for some=20
 networks, even with plentiful IPv6 addresses.

 Claims and use of NAT as a security, load balancing, and routing=20
 control is where most of the nasty side effects and behaviours are=20
 streaming in from.

 AYJ

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
