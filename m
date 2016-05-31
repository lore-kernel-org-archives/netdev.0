From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [net v3] veth: advertise peer link once both links are tied together
Date: Tue, 31 May 2016 08:29:29 +0200
Message-ID: <m3fusyg2pi.fsf@neo.luffy.cx>
References: <574C6095.9050804@6wind.com>
	<1464623917-11536-1-git-send-email-vincent@bernat.im>
	<87bn3n358j.fsf@zoro.exoscale.ch> <574C69DE.3050305@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:44849 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755946AbcEaG3d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 02:29:33 -0400
In-Reply-To: <574C69DE.3050305@6wind.com> (Nicolas Dichtel's message of "Mon,
	30 May 2016 18:27:10 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 30 mai 2016 18:27 CEST, Nicolas Dichtel <nicolas.dichtel@6wi=
nd.com>=C2=A0:

>>> +
>>> +	rtmsg_ifinfo(RTM_NEWLINK, peer, IFF_SLAVE, GFP_KERNEL);
>>=20
>> Maybe ~0U would be better than hijacking IFF_SLAVE?
> IFF_SLAVE is wrong. It's a flag here, that will be put in the ifi_cha=
nge field
> not an attribute number.

There are some use of IFF_SLAVE (in bonding/bond_main.c). But, I'll
update the patch nonetheless.
--=20
Use free-form input when possible.
            - The Elements of Programming Style (Kernighan & Plauger)
