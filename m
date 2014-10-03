From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH 2/2] net: spider_net: avoid using signed char for bitops
Date: Fri, 3 Oct 2014 17:17:24 +0200
Message-ID: <20141003151724.GB20398@kwain>
References: <1412348517-20352-1-git-send-email-antoine.tenart@free-electrons.com>
 <1412348517-20352-4-git-send-email-antoine.tenart@free-electrons.com>
 <9201792.OAu7xPjvdN@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org,
	Antoine Tenart <antoine.tenart@free-electrons.com>,
	dan.carpenter@oracle.com, kou.ishizaki@toshiba.co.jp,
	jens@de.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:46903 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751773AbaJCPR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 11:17:28 -0400
Content-Disposition: inline
In-Reply-To: <9201792.OAu7xPjvdN@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

On Fri, Oct 03, 2014 at 05:15:05PM +0200, Arnd Bergmann wrote:
> On Friday 03 October 2014 17:01:56 Antoine Tenart wrote:
> > Signedness bugs may occur when using signed char for bitops,
> > depending on if the highest bit is ever used.
> >=20
> > Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> >=20
>=20
> It's probably worth mentioning here that this cannot happen in this
> driver because it's only used in one powerpc-specific chip, and 'char=
'
> is always 'unsigned' on powerpc.

Oh, that's good to know :)


Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
