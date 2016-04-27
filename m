From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] ARM: dts: at91: VInCo: fix phy reset gpio flag
Date: Wed, 27 Apr 2016 09:15:40 +0200
Message-ID: <5720671C.9040406@atmel.com>
References: <570BF481.9070903@cogentembedded.com>
 <1461666272-10107-1-git-send-email-nicolas.ferre@atmel.com>
 <20160426.131750.433048061726795876.davem@davemloft.net>
 <571FB305.4060304@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<gregory.clement@free-electrons.com>,
	<alexandre.belloni@free-electrons.com>, <netdev@vger.kernel.org>,
	<andrew@lunn.ch>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:50163 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314AbcD0HP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 03:15:27 -0400
In-Reply-To: <571FB305.4060304@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/04/2016 20:27, Sergei Shtylyov a =E9crit :
> On 04/26/2016 08:17 PM, David Miller wrote:
>=20
>>> I plan to queue this patch through arm-soc for 4.7.
>>
>> Ok.
>=20
>     How about this patch going thru your net-next repo instead?
> I'd like to keep the kernel bisectable... if my phylib/macb patches g=
et merged=20
> earlier than this one, that board would be broken...

Sergei, David,

I don't think that there is a big risk for this board to be tested in
the meantime as it's not widely deployed yet.
And as I'm aware of the issue and basically maintaining this DT file, I
think that I'll be informed if people try an unlikely arrangement of
patches on this board.

So either way, I'm okay. But I do think it's not worth thinking too muc=
h
about this case.

Bye,
--=20
Nicolas Ferre
