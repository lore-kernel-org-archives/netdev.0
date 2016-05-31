From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [net v3] veth: advertise peer link once both links are tied
 together
Date: Tue, 31 May 2016 11:17:20 +0200
Message-ID: <574D56A0.3090606@6wind.com>
References: <574C6095.9050804@6wind.com>
 <1464623917-11536-1-git-send-email-vincent@bernat.im>
 <87bn3n358j.fsf@zoro.exoscale.ch> <574C69DE.3050305@6wind.com>
 <m3fusyg2pi.fsf@neo.luffy.cx>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
To: Vincent Bernat <vincent@bernat.im>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35544 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756751AbcEaJRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 05:17:23 -0400
Received: by mail-wm0-f51.google.com with SMTP id a136so120752376wme.0
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 02:17:22 -0700 (PDT)
In-Reply-To: <m3fusyg2pi.fsf@neo.luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 31/05/2016 08:29, Vincent Bernat a =C3=A9crit :
>  =E2=9D=A6 30 mai 2016 18:27 CEST, Nicolas Dichtel <nicolas.dichtel@6=
wind.com> :
>=20
>>>> +
>>>> +	rtmsg_ifinfo(RTM_NEWLINK, peer, IFF_SLAVE, GFP_KERNEL);
>>>
>>> Maybe ~0U would be better than hijacking IFF_SLAVE?
>> IFF_SLAVE is wrong. It's a flag here, that will be put in the ifi_ch=
ange field
>> not an attribute number.
>=20
> There are some use of IFF_SLAVE (in bonding/bond_main.c). But, I'll
> update the patch nonetheless.
Sorry, I read it too quickly, IFF_SLAVE is a flag, not an attribute.
But this field indicates to the userland which flags has changed and th=
is flag
does not change here ;-)
