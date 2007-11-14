From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH 5/6] e1000: Secondary unicast address support
Date: Wed, 14 Nov 2007 01:48:21 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0711140141320.15397@bizon.gios.gov.pl>
References: <20071113231110.13177.27339.stgit@localhost.localdomain>
 <20071113231133.13177.84769.stgit@localhost.localdomain>
 <Pine.LNX.4.64.0711140113400.15397@bizon.gios.gov.pl> <473A3EE9.4040700@candelatech.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1237189055-1195001301=:15397"
Cc: Auke Kok <auke-jan.h.kok@intel.com>, davem@davemloft.net,
	jeff@garzik.org, netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:47940 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758943AbXKNAsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 19:48:52 -0500
In-Reply-To: <473A3EE9.4040700@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1237189055-1195001301=:15397
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 13 Nov 2007, Ben Greear wrote:

> Krzysztof Oledzki wrote:
>>=20
>>=20
>> On Tue, 13 Nov 2007, Auke Kok wrote:
>>=20
>>> From: Patrick McHardy <kaber@trash.net>
>>>=20
>>> Add support for configuring secondary unicast addresses. Unicast
>>> addresses take precendece over multicast addresses when filling
>>> the exact address filters to avoid going to promiscous mode.
>>> When more unicast addresses are present than filter slots,
>>> unicast filtering is disabled and all slots can be used for
>>> multicast addresses.
>>=20
>> Is there any easy way to use it for VRRP? It would be really great to ha=
ve=20
>> two IP addresses on the same interface, each with a different hw address=
=2E
>
> mac-vlans should do this for you..with our without the driver patch.

I'm afraid mac-vlans is not a solution here. Having 2x more interfaces=20
(ex. 2000 instead of 1000) makes everything (especially routing,=20
firewalling and QoS) much more complicated. It would be nice to have=20
something like "ip addr add a.b.c.d/24 dev vlan32 hwaddress=20
aa:bb:cc:dd:ee:ff".

BTW: is it possible to stack mac-vlans ontop of .1Q vlans?

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1237189055-1195001301=:15397--
