From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: linux-2.6.17(.6): bnx2.c:(.text+0xd741e): undefined
 reference to `crc32_le'
Date: Mon, 24 Jul 2006 13:00:33 -0700
Message-ID: <1153771233.3167.8.camel@rh4>
References: <200607211406.39982.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:41221 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1751305AbWGXT7D convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 15:59:03 -0400
To: "Toralf =?ISO-8859-1?Q?F=F6rster?=" <toralf.foerster@gmx.de>
In-Reply-To: <200607211406.39982.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-07-21 at 05:06 -0700, Toralf F=C3=B6rster wrote:
> Compiling  (an exotic ?) config I got:
>=20
> ...
>  CC      init/version.o
>   LD      init/built-in.o
>   LD      .tmp_vmlinux1
> drivers/built-in.o: In function `bnx2_set_rx_mode':
> bnx2.c:(.text+0xd741e): undefined reference to `crc32_le'
> drivers/built-in.o: In function `bnx2_test_nvram':
> bnx2.c:(.text+0xd9a5f): undefined reference to `crc32_le'
> bnx2.c:(.text+0xd9a83): undefined reference to `crc32_le'
> make: *** [.tmp_vmlinux1] Error 1
>=20
BNX2 requires the CRC32 library and the current kernels do not have tha=
t
dependency in the Kconfig.  This has been fixed and will be in 2.6.18.

=46or now, you can turn on CONFIG_CRC32 (to y) and that should fix the
problem.

Thanks.

