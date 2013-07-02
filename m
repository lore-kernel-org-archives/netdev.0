From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH v2] net: cdc_ether: allow combined control and data interface
Date: Tue, 02 Jul 2013 10:17:51 +0200
Message-ID: <1422740.WTESdOQgPZ@linux-5eaq.site>
References: <1372500186-23567-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Enrico Mioso <mrkiko.rs@gmail.com>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:57760 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932167Ab3GBIQS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 04:16:18 -0400
In-Reply-To: <1372500186-23567-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 29 June 2013 12:03:06 Bj=F8rn Mork wrote:
> Some Icera based Huawei modems handled by this driver are not
> completely CDC ECM compliant, using the same USB interface for both
> control and data. The CDC functional descriptors include a Union
> naming this interface as both master and slave, so it is supportable
> by relaxing the descriptor parsing in case these interfaces are
> identical.
>=20
> This has been tested on a Huawei K3806 and verified to add support
> for that device.
>=20
> Reported-and-tested-by: Enrico Mioso <mrkiko.rs@gmail.com>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
Acked-by: Oliver Neukum <oliver@neukum.org>
