From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: [GIT/PATCH 0/2] Minor fixes to xen-netfront
Date: Thu, 19 Aug 2010 10:27:35 +0100
Message-ID: <1282210055.3170.2283.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>, xen-devel <xen-devel@lists.xensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:59747 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab0HSJ1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 05:27:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think these are likely for 2.6.37 but if possible the ethtool one
would be nice to have for 2.6.36 since 2.6.36 adds PVHVM support for Xen
(paravirtual drivers for fully-virtualised guests) so it is useful to be
able to see explicitly if eth0 is emulated or PV without having to infer
xen-netfront from:
        # ethtool -i eth0
        Cannot get driver information: Operation not supported

The following changes since commit da5cabf80e2433131bf0ed8993abc0f7ea618c73:
  Linus Torvalds (1):
        Linux 2.6.36-rc1

are available in the git repository at:

  git://xenbits.xensource.com/people/ianc/linux-2.6.git for-netdev/xen-netfront

Ian Campbell (2):
      xen: use less generic names in netfront driver.
      xen: netfront: support the ethtool drvinfo hook.

 drivers/net/xen-netfront.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

Ian.


