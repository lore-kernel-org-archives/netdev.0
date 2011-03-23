From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-2.6 2011-03-23
Date: Wed, 23 Mar 2011 21:14:33 +0000
Message-ID: <1300914873.2638.19.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:54846 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877Ab1CWVOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 17:14:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 736561a01f11114146b1b7f82d486fa9c95828ef:

  IPVS: Use global mutex in ip_vs_app.c (2011-03-21 20:39:24 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-2.6.git sfc-2.6.39

Bug fix for the latest optimisation.

Ben.

Steve Hodgson (1):
      sfc: Siena: Disable write-combining when SR-IOV is enabled

 drivers/net/sfc/efx.c         |   18 ++++++++++++++++--
 drivers/net/sfc/workarounds.h |    2 ++
 2 files changed, 18 insertions(+), 2 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

