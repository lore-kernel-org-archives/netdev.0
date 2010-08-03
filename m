From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [GIT PULL] xen-netfront driver updates for 2.6.36
Date: Tue, 03 Aug 2010 11:39:45 -0700
Message-ID: <4C586271.3010902@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	"Xen-devel@lists.xensource.com" <Xen-devel@lists.xensource.com>,
	"Xu, Dongxiao" <dongxiao.xu@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from claw.goop.org ([74.207.240.146]:60095 "EHLO claw.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754753Ab0HCSjv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 14:39:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

OK, let's try that again.

Here's a git branch with some updates to the Xen netfront driver, which 
add a new "smartpoll" mode to the netfront backend protocol, which is 
basically equivalent to interrupt mitigation.  This merges cleanly with 
current linux-next (it previously just had a small constification conflict).

Do you want to take this via the net tree, or are you OK with me 
submitting them directly?

Thanks,
     J

The following changes since commit 9fe6206f400646a2322096b56c59891d530e8d51:

   Linux 2.6.35 (2010-08-01 15:11:14 -0700)

are available in the git repository at:
   git://git.kernel.org/pub/scm/linux/kernel/git/jeremy/xen.git 
upstream/netfront

Dongxiao Xu (1):
       xen/netfront: Use smart polling instead of event notification.

Ian Campbell (2):
       xen/rings: make protocol specific usage of shared sring explicit
       xen/netfront: make protocol specific usage of shared sring explicit

  drivers/net/xen-netfront.c      |  114 
++++++++++++++++++++++++++++++++++++++-
  include/xen/interface/io/ring.h |   11 ++++-
  2 files changed, 122 insertions(+), 3 deletions(-)

