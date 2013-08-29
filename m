From: Rob Gardner <robmatic@gmail.com>
Subject: Re: [PATCH net,stable] net: usb: Add HP hs2434 device to ZLP
 exception table
Date: Wed, 28 Aug 2013 18:40:22 -0600
Message-ID: <20130828184022.9a5b54e8df63aaf8c82bf9b5@gmail.com>
References: <20130825182913.2865aa1a8cefe329ab9c7a85@gmail.com>
	<20130828.182332.824853790331642993.davem@davemloft.net>
	<20130828171812.7097dc8334046b464486d4a3@gmail.com>
	<20130828.200111.1548126886406334118.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org, bjorn@mork.no,
	oliver@neukum.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:44284 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755213Ab3H2AkZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 20:40:25 -0400
In-Reply-To: <20130828.200111.1548126886406334118.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Aug 2013 20:01:11 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Rob Gardner <robmatic@gmail.com>
> Date: Wed, 28 Aug 2013 17:18:12 -0600
>=20
> > Bj=F8rn says it could have a minor performance impact, but should n=
ot
> > cause any loss of functionality. I don't think there's any hard dat=
a on
> > what the performance cost might be but I know he would eventually l=
ike
> > to get rid of the exception list and live with the possible perform=
ance
> > impact if it means functionality for more devices.
>=20
> Therefore I would recommend turning the workaround on by default and
> have a white list.

The exception list means "usb_device_id entries for specific devices
that are known to need the workaround." There are just two such entries=
=2E
There isn't even a separate list. So maybe we just have a nomenclature
problem, and we could simply be calling this a "white list" instead of
"exception list". The other possible meaning of whitelist (all devices
that *don't* need the workaround) is unthinkable, as that would be a hu=
ge
list and much more prone to be unmanageable than what we've got now.

--=20
Rob Gardner <robmatic@gmail.com>
