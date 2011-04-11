From: sjur.brandeland@stericsson.com
Subject: [PATCH 0/2] caif: Bugfixes
Date: Mon, 11 Apr 2011 22:11:28 +0200
Message-ID: <1302552691-11874-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:53720 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755846Ab1DKULf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 16:11:35 -0400
Received: from terra-smin.broadpark.no ([80.202.8.13])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LJI0095X83AEF90@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Mon, 11 Apr 2011 22:11:34 +0200 (CEST)
Received: from localhost.localdomain ([80.203.137.187])
 by terra-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LJI007NQ83ANZZ0@terra-smin.broadpark.no> for
 netdev@vger.kernel.org; Mon, 11 Apr 2011 22:11:34 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

Hi Dave,

These two patches applies cleanly to net-2.6 and net-next-2.6.
Please apply as you see apropriate.

The first patch fixes a kernel panic.
The second patch fixes a CAIF protocol bug. This bug caused packet
prioritization to be disabled on the modem, resulting in bad throughput=
=2E

Regards,
Sjur

Sjur Br=C3=A6ndeland (2):
  caif: Bugfix use for_each_safe when removing list nodes.
  caif: performance bugfix - allow radio stack to prioritize packets.

 net/caif/cfdgml.c |    6 +++++-
 net/caif/cfmuxl.c |    4 ++--
 2 files changed, 7 insertions(+), 3 deletions(-)

