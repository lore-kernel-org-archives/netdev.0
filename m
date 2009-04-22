From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: What makes a good fake MAC address?
Date: Wed, 22 Apr 2009 14:28:03 -0700
Message-ID: <200904221428.03539.inaky@linux.intel.com>
References: <200904221348.27357.inaky@linux.intel.com> <49EF8891.9010306@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:46176 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754291AbZDVV2H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 17:28:07 -0400
In-Reply-To: <49EF8891.9010306@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 22 April 2009, Eric Dumazet wrote:
> Inaky Perez-Gonzalez a =E9crit :
> > Hi All
> >
> > The Intel i2400m WiMAX driver behaves as an ethernet device, and
> > currently when sending packets to the netdev stack, it fakes an eth=
ernet
> > header, sets the "from" mac address to zeroes and the "to" to it's =
own
> > MAC address.
> >
> > The WiMAX network can be considered to be a point-to-point (up to t=
he
> > gateway) connection, all IP based, so there are not MAC addresses f=
rom
> > our gateway (not to mention that it can change behind us).
> >
> > The problem with using a zero mac address is that it confuses the
> > bridging software (and maybe others). I was wondering, what would b=
e a
> > fake mac address we could put in there that is legal for this kind =
of
> > "faking"? [or the closest thing to legal?]
> >
> > Thanks!
>
> We have random_ether_addr(), it should be self explained :)

(Also in reply to Stephen's comment) the device has its own local addre=
ss;=20
what we are faking is the address the packet comes from.

According to random_ether_addr(), it sets the local bits; will this wor=
k to=20
fake the "other end of the connection"? (for which there is an IP addre=
ss but=20
no MAC address, it being a pure IP link).

Thanks,

--=20
Inaky
