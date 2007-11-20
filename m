From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv6 0/3] Interface group patches
Date: Tue, 20 Nov 2007 13:42:42 -0800 (PST)
Message-ID: <20071120.134242.177093096.davem@davemloft.net>
References: <11955644701165-git-send-email-panther@balabit.hu>
	<Pine.LNX.4.64.0711201425530.32378@fbirervta.pbzchgretzou.qr>
	<4742E68C.2000802@balabit.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jengelh@computergmbh.de, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: panther@balabit.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4742E68C.2000802@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Laszlo Attila Toth <panther@balabit.hu>
Date: Tue, 20 Nov 2007 14:52:12 +0100

> Jan Engelhardt =EDrta:
> > On Nov 20 2007 14:14, Laszlo Attila Toth wrote:
> >> This is the 6th version of our interface group patches.
> >>
> >> The interface group value can be used to manage different interfac=
es
> >> at the same time such as in netfilter/iptables.
> >=20
> > I take it you could not use...?
> > 	iptables -i iif1 -j dosomething
> > 	iptables -i iif2 -j dosomething
>=20
> This kind of usage requires static interface names. But there are=20
> dynamic interfaces such as ppp, where the actual name is not always=20
> known or sometimes they exist sometimes not. It is difficult to use=20
> iptables this way, and every ifup/ifdown requires change in the iptab=
les=20
> ruleset (donwload it, modify and upload to the kernel). It may be too=
 slow.

This is actually not true these days.

When network devices are created user events are generated and the
user can rename the device however they like using a mapping table of
any kind.

And at such point the problem you present doesn't actually exist, you
can know what the device will be named.

And if rule loading dynamically is slow, we should fix that instead of
creating infrastructure and interfaces we don't actually need.
-
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
