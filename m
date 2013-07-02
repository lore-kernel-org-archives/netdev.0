From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH v2] net: cdc_ether: allow combined control and data interface
Date: Tue, 02 Jul 2013 11:06:11 +0200
Message-ID: <2685127.bhjI3sgKXj@linux-5eaq.site>
References: <1372500186-23567-1-git-send-email-bjorn@mork.no> <20130701.233817.1253947554176449518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn@mork.no, netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	mrkiko.rs@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:42043 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932225Ab3GBJEi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 05:04:38 -0400
In-Reply-To: <20130701.233817.1253947554176449518.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 01 July 2013 23:38:17 David Miller wrote:
> From: Bj=F8rn Mork <bjorn@mork.no>
> Date: Sat, 29 Jun 2013 12:03:06 +0200
>=20
> > Some Icera based Huawei modems handled by this driver are not
> > completely CDC ECM compliant, using the same USB interface for both
> > control and data. The CDC functional descriptors include a Union
> > naming this interface as both master and slave, so it is supportabl=
e
> > by relaxing the descriptor parsing in case these interfaces are
> > identical.
> >=20
> > This has been tested on a Huawei K3806 and verified to add support
> > for that device.
> >=20
> > Reported-and-tested-by: Enrico Mioso <mrkiko.rs@gmail.com>
> > Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
> > ---
> > v2: Simplified unbind logic.  Thanks to Oliver Neukum
>=20
> Oliver if you could give this a quick review, that would be
> great.

Done.

	Sorry for the delay
		Oliver
