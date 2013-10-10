From: Simon Horman <horms+renesas@verge.net.au>
Subject: [GIT PULL] Renesas SH ethernet fix for v3.12
Date: Thu, 10 Oct 2013 14:51:15 +0900
Message-ID: <1381384276-8077-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Nguyen Hong Ky <nh-ky@jinso.co.jp>,
	Simon Horman <horms+renesas@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46878 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754244Ab3JJFvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 01:51:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

please consider this fix for SH ethernet fix for v3.12.
I am sending it as a pull-request rather than a stand-alone
patch as it resolves the miss-application of a patch and I wanted
to eliminate the chance of further miss-application.

That said, I am happy for you to just apply the patch rather
than do a git pull. But you may want to check that the result
is the same as what is present in my tag.


The following changes since commit 5abbeea553c8260ed4e2ac4aae962aff800b6c6d:

  can: at91-can: fix device to driver data mapping for platform devices (2013-10-09 23:04:31 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/renesas.git tags/renesas-sh_eth-fixes-for-v3.12

for you to fetch changes up to 31c827b594a0eb7c996510a93338b6096e8565e6:

  net: sh_eth: Correct fix for RX packet errors on R8A7740 (2013-10-10 14:42:15 +0900)

----------------------------------------------------------------
Renesas SH ethernet fix for v3.12

* Revised fix from Nguyen Hong Ky for
  RX packet errors on the R8A7740 SoC

----------------------------------------------------------------
Simon Horman (1):
      net: sh_eth: Correct fix for RX packet errors on R8A7740

 drivers/net/ethernet/renesas/sh_eth.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)
