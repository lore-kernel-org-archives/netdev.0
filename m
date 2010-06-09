From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFS seems to have incompatiblities with bridged vlans
Date: Wed, 09 Jun 2010 06:42:33 +0200
Message-ID: <1276058553.2439.469.camel@edumazet-laptop>
References: <62C40338-045A-417E-9B90-E59A320E1343@dlh.net>
	 <20100607145910.2458ac87@nehalam>	<4C0D7312.1020300@intel.com>
	 <1276006721.2486.141.camel@edumazet-laptop>
	 <AANLkTiluIibUglhf28JAeSLzBC0E1Zw0STPoqFTbXcev@mail.gmail.com>
	 <4C0ED931.6030402@canonical.com>  <4C0EE99B.8030300@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "tim.gardner@canonical.com" <tim.gardner@canonical.com>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Peter Lieven <pl@dlh.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41831 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106Ab0FIEmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 00:42:39 -0400
Received: by wyf28 with SMTP id 28so614867wyf.19
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 21:42:38 -0700 (PDT)
In-Reply-To: <4C0EE99B.8030300@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 08 juin 2010 =C3=A0 18:08 -0700, John Fastabend a =C3=A9crit :


>=20
> The bonding driver is already multiq per Andy Gospodarek's patch comm=
it bb1d912,=20
> but unless the bond and bridge devices use the max num_rx_queues of t=
here=20
> underlying devices this could still go wrong.
>=20

This patch is in net-next-2.6, it is not scheduled for 2.6.35

We need some fix for 2.6.35

> The bonding driver would possibly need to increase num_rx_queues and=20
> num_tx_queues when a device is enslaved or be set to some maximum at =
init for=20
> this to work right.

Thats a bit complex and definitly not 2.6.35 material.



