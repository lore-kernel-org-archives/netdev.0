From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] cdc-ether: clean packet filter upon probe
Date: Mon, 25 Aug 2014 14:13:42 +0200
Message-ID: <1408968822.10300.18.camel@linux-fkkt.site>
References: <1406537796-20156-1-git-send-email-oneukum@suse.de>
	 <87a977z5pn.fsf@nemi.mork.no> <1408083121.17565.4.camel@linux-fkkt.site>
	 <87d2c2xm2k.fsf@nemi.mork.no> <1408954063.10300.1.camel@linux-fkkt.site>
	 <87a96tc692.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46425 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751731AbaHYMNo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2014 08:13:44 -0400
In-Reply-To: <87a96tc692.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-08-25 at 10:39 +0200, Bj=C3=B8rn Mork wrote:
> Oliver Neukum <oneukum@suse.de> writes:
> > On Fri, 2014-08-15 at 09:13 +0200, Bj=C3=B8rn Mork wrote:
> >> Oliver Neukum <oneukum@suse.de> writes:
> >>=20
> >> > On Thu, 2014-08-14 at 13:11 +0200, Bj=C3=B8rn Mork wrote:
> >
> >> > Support for this request is mandatory.
> >>=20
> >> Yes, there is no problem for standard conforming ECM devices.  I f=
ully
> >> agree there.=20
> >>=20
> >> But standard conformance is unfortunately not something we can exp=
ect.
> >> My question was regarding the non-conforming devices, like the one=
s
> >> supported by th zaurus and rndis_host drivers.  These drivers are =
made
> >
> > You have a point. Yet another flag? Do you see an alternative?
>=20
> Note that I don't know whether this is a real problem or not. I don't
> believe I have any zaurus or rndis_host devices.
>=20
> But how about just splitting the .bind functions for true ECM devices
> and the others, letting the zaurus and rndis_host driver continue to =
use
> usbnet_cdc_bind with no filter setting?  Maybe define a new unexporte=
d
> .bind in cdc_ether for this purpose, moving the ECM specific
> initialization there?
>=20
> Maybe something along this (instead of the change to
> usbnet_generic_cdc_bind)?:

Yes, that looks superior.

	Regards
		Oliver
