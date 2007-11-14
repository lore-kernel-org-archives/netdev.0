From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 5/6] e1000: Secondary unicast address support
Date: Tue, 13 Nov 2007 16:18:49 -0800
Message-ID: <473A3EE9.4040700@candelatech.com>
References: <20071113231110.13177.27339.stgit@localhost.localdomain> <20071113231133.13177.84769.stgit@localhost.localdomain> <Pine.LNX.4.64.0711140113400.15397@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Auke Kok <auke-jan.h.kok@intel.com>, davem@davemloft.net,
	jeff@garzik.org, netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:33889 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760210AbXKNATQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 19:19:16 -0500
In-Reply-To: <Pine.LNX.4.64.0711140113400.15397@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Oledzki wrote:
>=20
>=20
> On Tue, 13 Nov 2007, Auke Kok wrote:
>=20
>> From: Patrick McHardy <kaber@trash.net>
>>
>> Add support for configuring secondary unicast addresses. Unicast
>> addresses take precendece over multicast addresses when filling
>> the exact address filters to avoid going to promiscous mode.
>> When more unicast addresses are present than filter slots,
>> unicast filtering is disabled and all slots can be used for
>> multicast addresses.
>=20
> Is there any easy way to use it for VRRP? It would be really great to=
=20
> have two IP addresses on the same interface, each with a different hw=
=20
> address.

mac-vlans should do this for you..with our without the driver patch.

Ben

>=20
> Best regards,
>=20
>                  Krzysztof Ol=EAdzki


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

