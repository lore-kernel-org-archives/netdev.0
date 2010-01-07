From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: cdc_ether.c: Add SE J105i to device whitelist
Date: Thu, 07 Jan 2010 09:50:01 +0100
Message-ID: <874omyqoxy.fsf@nemi.mork.no>
References: <1261601807-8385-1-git-send-email-tloo@saltstorm.net>
	<1261604906.609.106.camel@localhost.localdomain>
	<878wcdx6tt.fsf@nemi.mork.no>
	<1262639441.16627.322.camel@localhost.localdomain>
	<87iqbhuhre.fsf@nemi.mork.no>
	<1262691113.16627.361.camel@localhost.localdomain>
	<87eim4vhvh.fsf@nemi.mork.no>
	<1262846321.3608.76.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:38332 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932506Ab0AGIuZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 03:50:25 -0500
In-Reply-To: <1262846321.3608.76.camel@localhost.localdomain> (Dan Williams's
	message of "Wed, 06 Jan 2010 22:38:41 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams <dcbw@redhat.com> writes:

> Here's the difference:
>
> F3507g: requires AT command setup before cdc-ether port is usable
> SE j105i: does not require AT command setup before port is usable
>
> Same on my TM-506; you can simply run DHCP on the 'usb0' port and it
> works, because the phone is pretending to be a usb-ethernet device an=
d
> transparently bridge between the ethernet and the cellular network.
> That's simply not the case with the F3507g or any other WWAN card.
>
> Phones are fundamentally different than WWAN cards and shouldn't be
> treated like one, at least at this time.

OK, then I misunderstood the request.  I thought that this phone behave=
d
like a WWAN card since it presumably advertised the same CDC "Mobile
Direct Line" class as the Ericsson WWAN cards, maybe even with the same
GUID in the MDLM header?

If it really behaves like you describe (which is what the other Sony
Ericsson phones I've seen does too), then I don't understand why it
doesn't just advertise a CDC Ethernet class device.  That's what the
other phones do, and as you of course know, the reason why we don't hav=
e
a gazillion phone VID/PID entries in cdc_ether.c..


Bj=C3=B8rn


