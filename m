From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Please revert removal of /sys/class/net/*/features
Date: Tue, 10 Apr 2012 21:25:47 +0100
Message-ID: <1334089547.2624.4.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120410110851.5690739c@nehalam.linuxnetplumber.net>
	 <20120410195956.GA28447@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:37579 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756128Ab2DJUZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 16:25:51 -0400
In-Reply-To: <20120410195956.GA28447@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 21:59 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Tue, Apr 10, 2012 at 11:08:51AM -0700, Stephen Hemminger wrote:
> > This commit needs to be reverted. It removed an available sysfs fil=
e, and sysfs
> > files are part of the ABI. It caused a bug in our current release o=
f Vyatta because
> > the shell script was using the sysfs file to see if VLAN was suppor=
ted on a device.
> >=20
> > An API maybe redundant, but you can't just remove it.
>=20
> There was a discussion about it before the patch was accepted. It was
> concluded that due to features flags changes, the /sys/class/net/*/fe=
atures
> was never a stable API.

=46or reference:
http://thread.gmane.org/gmane.linux.network/199115/focus=3D199136

But note that the VLAN-related feature flags never actually changed
value.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
