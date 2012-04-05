From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 3/3] ixgbe: add syfs interface for to export read
 only driver information
Date: Thu, 05 Apr 2012 18:49:35 -0400 (EDT)
Message-ID: <20120405.184935.422690748002137749.davem@davemloft.net>
References: <1333622878-3855-4-git-send-email-jeffrey.t.kirsher@intel.com>
	<4F7D8DD4.5080205@openwrt.org>
	<1333643525.2652.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: florian@openwrt.org, jeffrey.t.kirsher@intel.com,
	donald.c.skidmore@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755545Ab2DEWtq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 18:49:46 -0400
In-Reply-To: <1333643525.2652.10.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 5 Apr 2012 17:32:05 +0100

> On Thu, 2012-04-05 at 14:19 +0200, Florian Fainelli wrote:
>> Hi,
>>=20
>> Le 04/05/12 12:47, Jeff Kirsher a =E9crit :
>> > From: Don Skidmore<donald.c.skidmore@intel.com>
>> >
>> > This patch exports non-thermal (which was done via hwmon in an ear=
lier
>> > patch) data to syfs.  All of the fields are read only as this inte=
rface
>> > is to only export driver data.
>> >
>> > Signed-off-by: Don Skidmore<donald.c.skidmore@intel.com>
>> > Tested-by: Stephen Ko<stephen.s.ko@intel.com>
>> > Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>> > ---
>>=20
>> I only looked briefly at the exported attributes, but most of them c=
an=20
>> already be queried using ethtool, can't they?
> [...]
>=20
> I agree, it looks like most of these are:
>=20
> (1) already exposed through ethtool commands (ETHTOOL_GSET,
> ETHTOOL_GDRVINFO, ETHTOOL_GLINK and ETHTOOL_GPERMADDR), or
> (2) already exposed through rtnetlink or the net device in sysfs, or
> (3) statistics that should be exposed through ETHTOOL_GSTATS
>=20
> I imagine there are some that don't fall into those categories, but I
> don't see why they should *all* be exposed in a non-standard and/or
> redundant way.

Agreed.
