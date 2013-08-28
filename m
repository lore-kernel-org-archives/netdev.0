From: Rob Gardner <robmatic@gmail.com>
Subject: Re: [PATCH net,stable] net: usb: Add HP hs2434 device to ZLP
 exception table
Date: Wed, 28 Aug 2013 17:18:12 -0600
Message-ID: <20130828171812.7097dc8334046b464486d4a3@gmail.com>
References: <20130825182913.2865aa1a8cefe329ab9c7a85@gmail.com>
	<20130828.182332.824853790331642993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org, bjorn@mork.no,
	oliver@neukum.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:44501 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119Ab3H1XSP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 19:18:15 -0400
In-Reply-To: <20130828.182332.824853790331642993.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Aug 2013 18:23:32 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Rob Gardner <robmatic@gmail.com>
> Date: Sun, 25 Aug 2013 18:29:13 -0600
>=20
> > From 018343ce2e679d97283fb51da25c43aa876d087a Mon Sep 17 00:00:00 2=
001
> > From: Rob Gardner <robmatic@gmail.com>
> > Date: Sun, 25 Aug 2013 16:02:23 -0600
> > Subject: [PATCH net,stable] net: usb: Add HP hs2434 device to ZLP e=
xception table
> >=20
> > This patch adds another entry (HP hs2434 Mobile Broadband) to the l=
ist
> > of exceptional devices that require a zero length packet in order t=
o
> > function properly. This list was added in commit 844e88f0. The hs24=
34
> > is manufactured by Sierra Wireless, who also produces the MC7710,
> > which the ZLP exception list was created for in the first place. So
> > hopefully it is just this one producer's devices that will need thi=
s
> > workaround.
> >=20
> > Tested on a DM1-4310NR HP notebook, which does not function without=
 this
> > change.
> >=20
> > Signed-off-by: Rob Gardner <robmatic@gmail.com>
>=20
> Applied and queued up for -tablt, thanks.
>=20
> On the topic of dealing with detection of this issue, how harmful is =
the
> workaround on chips that don't need it?  Will the driver not work in =
that
> case?


Bj=F8rn says it could have a minor performance impact, but should not
cause any loss of functionality. I don't think there's any hard data on
what the performance cost might be but I know he would eventually like
to get rid of the exception list and live with the possible performance
impact if it means functionality for more devices.


--=20
Rob Gardner <robmatic@gmail.com>
