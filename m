From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [GIT PULL] vhost-net fixes
Date: Fri, 16 Jul 2010 15:25:30 +0300
Message-ID: <20100716122530.GA29478@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59833 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965312Ab0GPMav (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jul 2010 08:30:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, please pull the following fixes for 2.6.35.
Thanks!

The following changes since commit 91a72a70594e5212c97705ca6a694bd307f7a26b:

  net/core: neighbour update Oops (2010-07-14 18:02:16 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net

Michael S. Tsirkin (2):
      vhost-net: avoid flush under lock
      vhost: avoid pr_err on condition guest can trigger

 drivers/vhost/net.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)
