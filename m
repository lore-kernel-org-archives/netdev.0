From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL net-next] vhost-net fixes for 3.1
Date: Tue, 19 Jul 2011 14:47:41 +0300
Message-ID: <20110719114741.GA5827@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, mashirle@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751265Ab1GSLrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 07:47:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's Jason's fix for a theoretical event loss
on migration (tweaked by me to update the test
module as well), and a refcounting fix by me
for a bug in the new zerocopy mode.

I thought hard about merging Jason's patches for 3.0
as well, but in the end I think it's not worth
the risk of breaking something at this stage.

Please pull for 3.1, thanks a lot!

The following changes since commit 81fc70d86527a1450560709500ca5f52e661da1f:

  net: can: remove custom hex_to_bin() (2011-07-18 11:31:43 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net-next

Jason Wang (2):
      vhost: init used ring after backend was set
      vhost: set log when updating used flags or avail event

Michael S. Tsirkin (1):
      vhost: fix zcopy reference counting

 drivers/vhost/net.c   |    4 ++
 drivers/vhost/test.c  |    5 +++
 drivers/vhost/vhost.c |   87 ++++++++++++++++++++++++++++++------------------
 drivers/vhost/vhost.h |    1 +
 4 files changed, 64 insertions(+), 33 deletions(-)
