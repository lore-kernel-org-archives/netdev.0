From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: Question: Section mismatch warnings in drivers/net
Date: Wed, 2 May 2012 16:30:25 -0700
Message-ID: <201205021630.25233.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello all,

I noticed a number of section mismatch warnings in various
drivers/net/ drivers. I was going to submit some patches to
clean them up but then saw these commits:

commit 948252cb9e01d65a89ecadf67be5018351eee15e
Author: David S. Miller <davem@davemloft.net>
Date:   Tue May 31 19:27:48 2011 -0700

    Revert "net: fix section mismatches"
   =20
    This reverts commit e5cb966c0838e4da43a3b0751bdcac7fe719f7b4.
   =20
    It causes new build regressions with gcc-4.2 which is
    pretty common on non-x86 platforms.
   =20
    Reported-by: James Bottomley <James.Bottomley@HansenPartnership.com=
>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit e5cb966c0838e4da43a3b0751bdcac7fe719f7b4
Author: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Date:   Mon Apr 18 13:31:20 2011 +0000

    net: fix section mismatches
   =20
    Fix build warnings like the following:
   =20
    WARNING: drivers/net/built-in.o(.data+0x12434): Section mismatch in=
 reference from the variable madge
   =20
    And add some consts to EISA device ID tables along the way.
   =20
    Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Was the issue with the build regressions ever worked out? Would
patches to fix the section mismatches be appropriate now?

Regards,
Hartley
