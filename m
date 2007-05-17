From: David Miller <davem@davemloft.net>
Subject: Re: linux-2.6.22-rc1-gb2cd6415 build #257 failed in
 ./net/rxrpc/ar-peer.c
Date: Thu, 17 May 2007 13:42:12 -0700 (PDT)
Message-ID: <20070517.134212.115909674.davem@davemloft.net>
References: <200705172106.27574.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: toralf.foerster@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55105
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754972AbXEQUmK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 16:42:10 -0400
In-Reply-To: <200705172106.27574.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Toralf F=F6rster <toralf.foerster@gmx.de>
Date: Thu, 17 May 2007 21:06:24 +0200

>=20
> Hello,
>=20
> the build with the attached .config failed, make ends with:
> ...
>   AS      arch/i386/lib/semaphore.o
>   CC      arch/i386/lib/strstr.o
>   CC      arch/i386/lib/usercopy.o
>   AR      arch/i386/lib/lib.a
>   GEN     .version
>   CHK     include/linux/compile.h
>   UPD     include/linux/compile.h
>   CC      init/version.o
>   LD      init/built-in.o
>   LD      .tmp_vmlinux1
> net/built-in.o: In function `rxrpc_assess_MTU_size':
> ar-peer.c:(.text+0x63fb8): undefined reference to `ip_route_output_ke=
y'
> make: *** [.tmp_vmlinux1] Error 1

I thought we made RXRPC depend upon IPV4, hmmm.

Nope, we didn't, I'll fix that, thanks for the report.
