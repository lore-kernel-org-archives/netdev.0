From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] net: fec: make driver endian-safe
Date: Mon, 25 Jan 2016 08:53:36 +0100
Message-ID: <1453708416.2164.0.camel@sipsolutions.net>
References: <1453650757-27459-1-git-send-email-johannes@sipsolutions.net>
	 <56A571C1.5050905@uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lucas Stach <l.stach@pengutronix.de>,
	Fugang Duan <B38611@freescale.com>,
	Arnd Bergmann <arnd@arndb.de>, Shawn Guo <shawnguo@kernel.org>
To: Greg Ungerer <gerg@uclinux.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:58946 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751458AbcAYHxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2016 02:53:42 -0500
In-Reply-To: <56A571C1.5050905@uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-01-25 at 10:52 +1000, Greg Ungerer wrote:
>=C2=A0
> I tested this on a ColdFire (5208) target that uses this driver.
> Simple testing showed it working with no problems. The ColdFire
> SoC processors use a version of the FEC hardware module, and they
> always run big-endian.
>=20

Great, thanks!

=46WIW, I failed to mention this - I did test the new version also on
little-endian ARM.

johannes
