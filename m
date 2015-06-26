From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net PATCH 1/1] net: phy: fix phy link up when limiting speed
 via device tree
Date: Fri, 26 Jun 2015 10:26:20 +0530
Message-ID: <558CDB74.9010508@ti.com>
References: <1435251062-5287-1-git-send-email-mugunthanvnm@ti.com> <558CC115.7000301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:44548 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751461AbbFZE4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2015 00:56:25 -0400
In-Reply-To: <558CC115.7000301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 26 June 2015 08:33 AM, Florian Fainelli wrote:
> Le 06/25/15 09:51, Mugunthan V N a =C3=A9crit :
>> > When limiting phy link speed using "max-speed" to 100mbps or less =
on a
>> > giga bit phy, phy never completes auto negotiation and phy state
>> > machine is held in PHY_AN. Fixing this issue by comparing the giga
>> > bit advertise though phydev->supported doesn't have it but phy has
>> > BMSR_ESTATEN set. So that auto negotiation is restarted as old and
>> > new advertise are different and link comes up fine.
>> >=20
>> > Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>=20

Dave

=46orgot to tag the patch to stable@vger.kernel.org for v4.1 lts, shoul=
d I
send a separate patch to Greg KH or you still hold a branch to be sent
for v4.1?

Regards
Mugunthan V N
