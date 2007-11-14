From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH 5/6] e1000: Secondary unicast address support
Date: Wed, 14 Nov 2007 02:17:40 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0711140210590.15397@bizon.gios.gov.pl>
References: <20071113231110.13177.27339.stgit@localhost.localdomain>
 <20071113231133.13177.84769.stgit@localhost.localdomain>
 <Pine.LNX.4.64.0711140113400.15397@bizon.gios.gov.pl> <473A3EE9.4040700@candelatech.com>
 <Pine.LNX.4.64.0711140141320.15397@bizon.gios.gov.pl> <473A49D7.2020400@candelatech.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-30170473-1195003060=:15397"
Cc: Auke Kok <auke-jan.h.kok@intel.com>, davem@davemloft.net,
	jeff@garzik.org, netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:45018 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759110AbXKNBSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 20:18:04 -0500
In-Reply-To: <473A49D7.2020400@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-30170473-1195003060=:15397
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 13 Nov 2007, Ben Greear wrote:

> Krzysztof Oledzki wrote:
>
>> I'm afraid mac-vlans is not a solution here. Having 2x more interfaces (=
ex.=20
>> 2000 instead of 1000) makes everything (especially routing, firewalling =
and=20
>> QoS) much more complicated. It would be nice to have something like "ip=
=20
>> addr add a.b.c.d/24 dev vlan32 hwaddress aa:bb:cc:dd:ee:ff".
>
> I'll take your word for it, though I have had good luck using mac-vlans
> in my own app.  They are nice because the are full-fledged interfaces,
> so you can treat them basically as .1q vlans or ethernet devices, includi=
ng
> all the routing and firewalling tricks.

OK. But in my situation it is going to be:

vlan1 (.1q) - real MAC
vlan1a (mac-vlan) - VRRP MAC
(...)
vlan999 (.1q) - real MAC
vlan999 (mac-vlan) - VRRP MAC

=2E.. with packets for the same destination coming in and out over both=20
interfaces depending on a src ip address.

>> BTW: is it possible to stack mac-vlans ontop of .1Q vlans?
>
> I believe it will work fine.  You could probably also stack .1q
> VLANs on top of mac-vlans so long as you use the same MAC for the VLANs a=
s=20
> for
> the mac-vlan dev.

So, this is something exactly I don't want to do as I need two different=20
MAC addresses. ;)

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-30170473-1195003060=:15397--
