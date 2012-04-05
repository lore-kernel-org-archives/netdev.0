From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 3/3] ixgbe: add syfs interface for to export read
 only driver information
Date: Thu, 5 Apr 2012 17:32:05 +0100
Message-ID: <1333643525.2652.10.camel@bwh-desktop.uk.solarflarecom.com>
References: <1333622878-3855-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1333622878-3855-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <4F7D8DD4.5080205@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:57060 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752087Ab2DEQcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 12:32:12 -0400
In-Reply-To: <4F7D8DD4.5080205@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-05 at 14:19 +0200, Florian Fainelli wrote:
> Hi,
>=20
> Le 04/05/12 12:47, Jeff Kirsher a =C3=A9crit :
> > From: Don Skidmore<donald.c.skidmore@intel.com>
> >
> > This patch exports non-thermal (which was done via hwmon in an earl=
ier
> > patch) data to syfs.  All of the fields are read only as this inter=
face
> > is to only export driver data.
> >
> > Signed-off-by: Don Skidmore<donald.c.skidmore@intel.com>
> > Tested-by: Stephen Ko<stephen.s.ko@intel.com>
> > Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> > ---
>=20
> I only looked briefly at the exported attributes, but most of them ca=
n=20
> already be queried using ethtool, can't they?
[...]

I agree, it looks like most of these are:

(1) already exposed through ethtool commands (ETHTOOL_GSET,
ETHTOOL_GDRVINFO, ETHTOOL_GLINK and ETHTOOL_GPERMADDR), or
(2) already exposed through rtnetlink or the net device in sysfs, or
(3) statistics that should be exposed through ETHTOOL_GSTATS

I imagine there are some that don't fall into those categories, but I
don't see why they should *all* be exposed in a non-standard and/or
redundant way.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
