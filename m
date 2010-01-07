From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] net: cdc_ether.c: Add SE J105i to device whitelist
Date: Thu, 07 Jan 2010 08:21:20 -0800
Message-ID: <1262881280.23268.50.camel@localhost.localdomain>
References: <1261601807-8385-1-git-send-email-tloo@saltstorm.net>
	 <1261604906.609.106.camel@localhost.localdomain>
	 <878wcdx6tt.fsf@nemi.mork.no>
	 <1262639441.16627.322.camel@localhost.localdomain>
	 <87iqbhuhre.fsf@nemi.mork.no>
	 <1262691113.16627.361.camel@localhost.localdomain>
	 <87eim4vhvh.fsf@nemi.mork.no>
	 <1262846321.3608.76.camel@localhost.localdomain>
	 <874omyqoxy.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64937 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753223Ab0AGQre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 11:47:34 -0500
In-Reply-To: <874omyqoxy.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-01-07 at 09:50 +0100, Bj=C3=B8rn Mork wrote:
> Dan Williams <dcbw@redhat.com> writes:
>=20
> > Here's the difference:
> >
> > F3507g: requires AT command setup before cdc-ether port is usable
> > SE j105i: does not require AT command setup before port is usable
> >
> > Same on my TM-506; you can simply run DHCP on the 'usb0' port and i=
t
> > works, because the phone is pretending to be a usb-ethernet device =
and
> > transparently bridge between the ethernet and the cellular network.
> > That's simply not the case with the F3507g or any other WWAN card.
> >
> > Phones are fundamentally different than WWAN cards and shouldn't be
> > treated like one, at least at this time.
>=20
> OK, then I misunderstood the request.  I thought that this phone beha=
ved
> like a WWAN card since it presumably advertised the same CDC "Mobile
> Direct Line" class as the Ericsson WWAN cards, maybe even with the sa=
me
> GUID in the MDLM header?

Interesting.  But I'd be very, very skeptical if the phone really acted
just like an MBM card.  My TM-506 has *some* of the same commands that
the F3507g and the F3607gw do but certainly not all of them.

> If it really behaves like you describe (which is what the other Sony
> Ericsson phones I've seen does too), then I don't understand why it
> doesn't just advertise a CDC Ethernet class device.  That's what the
> other phones do, and as you of course know, the reason why we don't h=
ave
> a gazillion phone VID/PID entries in cdc_ether.c..

Good question; though I've seen enough hardware that I'll simply just
assume they did it differently just because they could, not for any
specific reason.  Don't over-estimate the intelligence of firmware
people, they are just as human as the rest of us :)

Dan


