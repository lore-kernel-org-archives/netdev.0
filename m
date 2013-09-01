From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/9] set addr_assign_type when inheriting a
 dev_addr
Date: Sat, 31 Aug 2013 22:50:57 -0400 (EDT)
Message-ID: <20130831.225057.1874268263797742541.davem@davemloft.net>
References: <1377878932-26881-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net, jiri@resnulli.us,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org, j@w1.fi,
	libertas-dev@lists.infradead.org, gregkh@linuxfoundation.org,
	devel@driverdev.osuosl.org, forest@alittletooquiet.net,
	stephen@networkplumber.org, dan.carpenter@oracle.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754831Ab3IACvA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 22:51:00 -0400
In-Reply-To: <1377878932-26881-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Fri, 30 Aug 2013 18:08:43 +0200

> Copying the dev_addr from a parent device is an operation
> common to a number of drivers. The addr_assign_type should
> be updated accordingly, either by reusing the value from
> the source device or explicitly indicating that the address
> is stolen by setting addr_assign_type to NET_ADDR_STOLEN.
>=20
> This patch set adds a helper copying both the dev_addr and
> the addr_assign_type, and use this helper in drivers which
> don't currently set the addr_assign_type. Using NET_ADDR_STOLEN
> might be more appropriate in some of these cases.  Please
> let me know, and I'll update the patch accordingly.
>=20
> Changes in v2:
>  - assuming addr_len =3D=3D ETH_ALEN to allow optimized memcpy
>  - dropped the vt6656 patch due to addr_len being unset in that drive=
r

Looks good, series applied, thanks.
