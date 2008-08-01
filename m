From: Simon Horman <horms@verge.net.au>
Subject: Re: build issue #539 for v2.6.27-rc1 :undefined reference to
	`NS8390_init'
Date: Fri, 1 Aug 2008 15:21:13 +1000
Message-ID: <20080801052112.GH27241@verge.net.au>
References: <200807291959.50418.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: p_gortmaker@yahoo.com, netdev@vger.kernel.org
To: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:44979 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699AbYHAFVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 01:21:15 -0400
Content-Disposition: inline
In-Reply-To: <200807291959.50418.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 29, 2008 at 07:59:47PM +0200, Toralf F=F6rster wrote:
> Hello,
>=20
> the build (.config attached) failed, make ends with :
> ...
>   GEN     .version
>   CHK     include/linux/compile.h
>   UPD     include/linux/compile.h
>   CC      init/version.o
>   LD      init/built-in.o
>   LD      vmlinux
> drivers/built-in.o: In function `ne_drv_resume':
> ne.c:(.text+0x63d44): undefined reference to `NS8390_init'
> drivers/built-in.o: In function `ne_block_output':
> ne.c:(.text+0x63fe4): undefined reference to `NS8390_init'
> drivers/built-in.o: In function `ne_probe1':
> ne.c:(.init.text+0x6cb4): undefined reference to `NS8390_init'
> make: *** [vmlinux] Error 1
>=20
> The build was made with :
> $>make randconfig; make clean; make

This should be fixed by "fix NE2000 linkage error" aka
d02a4e31ed0385eb34fe49f19d69a860a020ca3c which has
been applied to net-2.6.


--=20
Horms

