From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next 8/9] ixgbe: add interface to export thermal data
Date: Fri, 6 Jan 2012 18:09:22 +0000
Message-ID: <1325873362.2850.20.camel@bwh-desktop>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1324631357-31789-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAHXqBFL_44T5nQVA=n03aT9Q1QpsLCY2dn9o6GE-9Rm66DSt-A@mail.gmail.com>
	 <F6FB0E698C9B3143BDF729DF22286646025656@ORSMSX102.amr.corp.intel.com>
	 <1325788584.3764.28.camel@bwh-desktop>
	 <F6FB0E698C9B3143BDF729DF22286646027184@ORSMSX102.amr.corp.intel.com>
	 <CAHXqBF+ZY-KH8hOi+QnDZVHx+8OOqP5CLXR44YtDLB3=1DDEOA@mail.gmail.com>
	 <363B5007A0D944459CBE9CF6A37B891B01E292@ORSMSX104.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Miroslaw <mirqus@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31941 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758883Ab2AFSJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 13:09:27 -0500
In-Reply-To: <363B5007A0D944459CBE9CF6A37B891B01E292@ORSMSX104.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-01-06 at 17:55 +0000, Waskiewicz Jr, Peter P wrote:
> > -----Original Message-----
> > From: Micha=C5=82 Miros=C5=82aw [mailto:mirqus@gmail.com]
> > Sent: Thursday, January 05, 2012 3:51 PM
> > To: Skidmore, Donald C
> > Cc: Ben Hutchings; Kirsher, Jeffrey T; davem@davemloft.net;
> > netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com;
> > Waskiewicz Jr, Peter P
> > Subject: Re: [net-next 8/9] ixgbe: add interface to export thermal =
data
> >=20
> > Drivers outside of drivers/hwmon just select HWMON in Kconfig. This=
 adds a
> > 3kB .c file to the kernel build for the first one that needs it.
>=20
> This is where we run into issues though.  We can put this dependency =
in, but
> customers don't pull upstream kernels, they rely on the OSV's to dist=
ribute
> updates.  The customer doesn't want HWMON, and if their kernel doesn'=
t ship
> with HWMON support for ixgbe, then we're sunk.

So if !IS_ENABLED(CONFIG_HWMON), don't try to create an hwmon device,
but create the attributes anyway.

> The point is what we're trying to implement, based on what our custom=
ers'
> requirements are, is something completely different than what HWMON i=
s
> providing.  Trying to wedge HWMON onto this framework we're trying to
> provide just overcomplicates the entire thing we're trying to provide=
=2E  It's
> a generic interface to generic data in our drivers,
[...]

It sounds like you want to provide a "generic" ixgbe interface on
different operating systems.  But that is not a valid argument for an
in-tree driver.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
