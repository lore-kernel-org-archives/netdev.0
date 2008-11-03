From: Manuel Lauss <mano@roarinelk.homelinux.net>
Subject: smc91x: commit 51ac3beffd4afaea4350526cf01fe74aaff25eff breaks
	compilation
Date: Mon, 3 Nov 2008 08:17:20 +0100
Message-ID: <20081103071720.GB18153@roarinelk.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Mike Frysinger <vapier@gentoo.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fnoeppeil48.netpark.at ([217.175.205.176]:35770 "EHLO
	roarinelk.homelinux.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752258AbYKCHRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 02:17:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Resend with correct netdev addr)

Hi Mike,

your commit 51ac3beffd4afaea4350526cf01fe74aaff25eff  causes this
compile failure on my SH and MIPS testboards (2.6.28-rc3):

 CC      drivers/net/smc91x.o
/mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_request_attrib':
/mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2067: error: 'lp' undeclared (first use in this function)
/mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2067: error: (Each undeclared identifier is reported only once
/mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2067: error: for each function it appears in.)
/mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_release_attrib':
/mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2079: error: 'lp' undeclared (first use in this function)
make[2]: *** [drivers/net/smc91x.o] Error 1
make[1]: *** [drivers/net/smc91x.o] Error 2

Reverting this commit fixes it.

Thanks,
        Manuel Lauss
