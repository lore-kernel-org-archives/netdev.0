From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc 2013-09-21
Date: Sat, 21 Sep 2013 18:45:04 +0100
Message-ID: <1379785504.1681.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:19816 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605Ab3IURpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 13:45:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit dcb30e659287a6b40dafed1362532da42ec27229:

  Merge tag 'arm64-stable' of git://git.kernel.org/pub/scm/linux/kernel/git/cmarinas/linux-aarch64 (2013-09-20 08:18:51 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.12

for you to fetch changes up to b2d32f03e67cc9b0ad16fc1fff87edf90f059883:

  sfc: Increase MCDI status timeout to 250ms (2013-09-20 17:24:35 +0100)

Daniel Pieczko fixed two bugs in reset handling that particularly
affected the new SFC9120 controller.

Ben.

----------------------------------------------------------------
Daniel Pieczko (2):
      sfc: Wait for MC reboot to complete before scheduling driver reset
      sfc: Increase MCDI status timeout to 250ms

 drivers/net/ethernet/sfc/mcdi.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
