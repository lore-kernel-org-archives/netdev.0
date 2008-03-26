From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Add support the Korina (IDT RC32434) Ethernet MAC
Date: Wed, 26 Mar 2008 00:36:19 -0400
Message-ID: <47E9D2C3.7050006@garzik.org>
References: <200803052345.06610.florian.fainelli@telecomint.eu> <200803131155.28164.florian.fainelli@telecomint.eu> <20080317223153.GA3462@electric-eye.fr.zoreil.com> <200803191714.52407.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Felix Fietkau <nbd@openwrt.org>
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34247 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755743AbYCZEgd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 00:36:33 -0400
In-Reply-To: <200803191714.52407.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46lorian Fainelli wrote:
> Hi Francois,
>=20
> Le lundi 17 mars 2008, Francois Romieu a =E9crit :
>>> Thanks for your comments, here is a third try which adresses the
>>> mentionned problems.
>=20
> It is allright, thanks for your concise answers. 1-2,4-15 should be f=
ixed now.
>=20
>> 3. korina_rx() still drops the received skb each time dev_alloc_skb =
fails.
>>    This is far from optimal.
>=20
> I now simply break into the while loop, which should allow more luck =
for failed allocation descriptors on next round. Seems like other=20
>=20
> Also, I fixed the multicast handling which was not done for filtered =
multicast traffic.
>=20
> Below is the fourth try of the driver.
> --
> From: Florian Fainelli <florian.fainelli@telecomint.eu>
> Subject: [PATCH] Add support the Korina (IDT RC32434) Ethernet MAC
>=20
> This patch adds support for the IDT rc32434 Ethernet MAC
> we can find in the IDT boards and the Mikrotik RB500.
> Driver references some code from the linux-mips RB500
> support.
>=20
> Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> Signed-off-by: Philip Rischel <rischelp@idt.com>

I applied this version...  please send changes after this as separate=20
patches


