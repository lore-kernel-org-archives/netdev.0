From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/21]: powerpc/cell spidernet bugfixes, etc.
Date: Wed, 11 Oct 2006 18:02:42 +0200
Message-ID: <200610111802.43996.arnd@arndb.de>
References: <20061010204946.GW4381@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@osdl.org, jeff@garzik.org, James K Lewis <jklewis@us.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:47297 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1161094AbWJKQDU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 12:03:20 -0400
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20061010204946.GW4381@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 10 October 2006 22:49, Linas Vepstas wrote:
> Andrew, please apply/forward upstream.
>=20
> The following set of 21 patches (!) are all aimed at the the=20
> spidernet ethernet device driver. The spidernet is an etherenet
> controller built into the Toshiba southbridge for the PowerPC Cell
> processor. (This is the only device in existance that with this
> ethernet hardware in it).
>=20
> These patches re-package/re-order/re-cleanup a previous
> set of patches I've previously mailed. Thus, some have
> been previously Acked-by lines, most do not. Most of
> these patches are tiny, and handle problems that cropped
> up during testing. Sorry about there being so many of them.
>=20
> The first set of 12 patches fix a large variety of mostly=20
> minor bugs.=20
>=20
> The important patches are 13 through 17: these overcome a=20
> debilitating performance problem on transmit (6 megabits
> per second !!) on transmit of patches 500 bytes or larger.
> After applying these, I am able to get the following:
>=20
> pkt sz =A0 speed (100K buffs) =A0 =A0 =A0 speed (4M buffs)
> ------ =A0 ----------------- =A0 =A0 =A0 =A0----------------
> 1500 =A0 =A0 700 Mbits/sec =A0 =A0 =A0 =A0 =A0 =A0951 Mbits/sec
> 1000 =A0 =A0 658 Mbits/sec =A0 =A0 =A0 =A0 =A0 =A0770
> 800 =A0 =A0 =A0600 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0648
> 500 =A0 =A0 =A0500 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0500
> 300 =A0 =A0 =A0372 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0372
> 60 =A0 =A0 =A0 =A070 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 70
>=20
> Above buf size refers to /proc/sys/net/core/wmem_default

Excellent work! I guess this the best tx performance we've
seen so far on this hardware.

Consider this as an Acked-by: for all the patches, I'll save
the effort of replying to each one of them separately.

Jeff, do you plan on merging these fixes for 2.6.19?

	Arnd <><
