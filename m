From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: gre: provide multicast mappings for ipv4 and ipv6
Date: Wed, 30 Mar 2011 00:11:31 -0700 (PDT)
Message-ID: <20110330.001131.200365288.davem@davemloft.net>
References: <1301388053-6083-1-git-send-email-timo.teras@iki.fi>
	<360171.1620.qm@web39305.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, timo.teras@iki.fi
To: rdkehn@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42427
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751868Ab1C3HMJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2011 03:12:09 -0400
In-Reply-To: <360171.1620.qm@web39305.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Doug Kehn <rdkehn@yahoo.com>
Date: Tue, 29 Mar 2011 13:26:02 -0700 (PDT)

>=20
> --- On Tue, 3/29/11, Timo Ter=E4s <timo.teras@iki.fi> wrote:
>=20
>> From: Timo Ter=E4s <timo.teras@iki.fi>
>> Subject: [PATCH] net: gre: provide multicast mappings for ipv4 and i=
pv6
>> To: netdev@vger.kernel.org
>> Cc: "Doug Kehn" <rdkehn@yahoo.com>, "Timo Ter=E4s" <timo.teras@iki.f=
i>
>> Date: Tuesday, March 29, 2011, 4:40 AM
>> My commit 6d55cb91a0020ac0 (gre: fix
>> hard header destination
>> address checking) broke multicast.
>>=20
>> The reason is that ip_gre used to get ipgre_header() calls
>> with
>> zero destination if we have NOARP or multicast destination.
>> Instead
>> the actual target was decided at ipgre_tunnel_xmit() time
>> based on
>> per-protocol dissection.
>>=20
>> Instead of allowing the "abuse" of ->header() calls with
>> invalid
>> destination, this creates multicast mappings for ip_gre.
>> This also
>> fixes "ip neigh show nud noarp" to display the proper
>> multicast
>> mappings used by the gre device.
>>=20
>> Reported-by: Doug Kehn <rdkehn@yahoo.com>
>> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>
>=20
> Acked-by: Doug Kehn <rdkehn@yahoo.com>

Applied.

Timo, if updates are necessary for the ipv4 mapped handling in ipv6,
please send that as a follow-up fix.

Thanks.
