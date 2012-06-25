From: sjur.brandeland@stericsson.com
Subject: [net-next 00/11] caif patch-set for net-next
Date: Mon, 25 Jun 2012 19:49:32 +0200
Message-ID: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34031 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587Ab2FYRtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 13:49:52 -0400
Received: by lbbgm6 with SMTP id gm6so6807265lbb.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 10:49:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

The first 8 patches are fixes,
there are a couple of fixes for issues found by static code analysis (c=
overity),
and some other misc cleanups/fixes.

The three last patches introduces rtnl for managing
the HSI interface and removes the use of module parameters.

Regards,
Sjur Br=C3=A6ndeland

Kim Lilliestierna XX (5):
  caif: Remove unused pointer and code
  caif: added check for potential null return
  caif: Fixed potential memory leak
  caif-hsi: Removed dead code
  caif-hsi: changed test on aggregation_timeout

Sjur Br=C3=A6ndeland (6):
  caif-hsi: Use netdev_X instead of dev_X for printing
  caif-hsi: Remove uncecessary assignments
  Documentation/networking/caif: Update documentation
  caif-hsi: Add rtnl support
  caif-hsi: Replace platform device with ops structure.
  caif-hsi: Remove use of module parameters

 Documentation/networking/caif/Linux-CAIF.txt |   91 ++---
 drivers/net/caif/caif_hsi.c                  |  547 ++++++++++++++----=
--------
 include/net/caif/caif_hsi.h                  |   71 +++--
 net/caif/caif_dev.c                          |    8 +-
 net/caif/cfctrl.c                            |   17 +-
 5 files changed, 378 insertions(+), 356 deletions(-)

--=20
1.7.5.4
