From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] USBNET: fix handling padding packet
Date: Wed, 18 Sep 2013 12:12:17 -0400 (EDT)
Message-ID: <20130918.121217.1293335702438057937.davem@davemloft.net>
References: <878uyu6xjm.fsf@nemi.mork.no>
	<CACVXFVNzTGbCV2wQ4RwxXK1q7+eD2KkOS_G3NvL4uAzdd21SUg@mail.gmail.com>
	<87zjra5dpx.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ming.lei@canonical.com, gregkh@linuxfoundation.org,
	oneukum@suse.de, netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	oliver@neukum.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35310 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357Ab3IRQMV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 12:12:21 -0400
In-Reply-To: <87zjra5dpx.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Wed, 18 Sep 2013 17:52:42 +0200

> Ming Lei <ming.lei@canonical.com> writes:
>=20
>> There is no reason to forbid DMA SG for one driver which requires
>> padding, right?
>=20
> Yes there is: Added complexity for everybody, based on a combination =
of
> features which just does not make any sense.
>=20
> No modern device should need the padding.  No old device will be able=
 to
> use the SG feature as implemented. You only enable it on USB3, don't
> you? If this feature is restricted to USB3 capable devices, then it m=
ost
> certainly can be restricted to ZLP capable devices with absolutely no
> difference in the resulting set of supported devices.

I completely agree.
