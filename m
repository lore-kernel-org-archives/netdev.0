From: Matthieu CASTET <matthieu.castet@parrot.com>
Subject: Re: Problem with non aligned DMA in usbnet on ARM
Date: Thu, 12 Aug 2010 19:01:20 +0200
Message-ID: <4C6428E0.8040402@parrot.com>
References: <AANLkTi=ycg=adcizNWKMCb7EdfDANM=6Es7r_gF1LbhV@mail.gmail.com> <20100811095454.GA22543@n2100.arm.linux.org.uk> <AANLkTimX46QKAGhiyo8AodaXVjuzoxr5-5z2V4gRr1Vu@mail.gmail.com> <20100811150443.GB8867@kroah.com> <AANLkTimmJDKbh3_pRY_ASKvjsf4YuuUMh3edh5LvDv-p@mail.gmail.com> <20100811174238.GA12382@kroah.com> <4C62F4EF.1050808@gmail.com> <20100811201332.GB10379@kroah.com> <4C6324B2.2080606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	linux-usb <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, <fchen@apm.com>
To: "mfuzzey@gmail.com" <mfuzzey@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co202.xi-lite.net ([149.6.83.202]:45117 "EHLO co202.xi-lite.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855Ab0HLRB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Aug 2010 13:01:26 -0400
In-Reply-To: <4C6324B2.2080606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Fuzzey a =E9crit :
> Greg KH wrote:
>> Can you fix this in the host controller driver?
>>
>>  =20
> Technically yes (by copying the unaligned buffers).
>=20
> But if we do decide that USB must support unaligned buffers wouldn't =
it
> be better to have the HCD indicate it's alignment requirement to the
> core and have the core do the copying?
>=20
> Gary King sent a message to this thread but only to the arm list sayi=
ng
> he has the same problem with the tegra hcd (which doesn't seem to be =
in
> the tree yet.)  I don't know if any of the other in tree HCDs have th=
is
> problem.
dwc otg also got this limitation. I don't know if the version submitted=
=20
for inclusion handle unaligned buffers.


Matthieu
