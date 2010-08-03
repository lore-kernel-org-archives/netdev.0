From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [GIT PULL] xen-netfront driver updates for 2.6.36
Date: Tue, 03 Aug 2010 11:11:20 -0700
Message-ID: <4C585BC8.5070203@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	"Xen-devel@lists.xensource.com" <Xen-devel@lists.xensource.com>,
	"Xu, Dongxiao" <dongxiao.xu@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  Hi Dave,

Here's a git branch with some updates to the Xen netfront driver, which 
add a new "smartpoll" mode to the netfront backend protocol, which is 
basically equivalent to interrupt mitigation.  They've been in 
linux-next for a week or so.

Do you want to take this via the net tree, or are you OK with me 
submitting them directly?

Thanks,
     J

The following changes since commit 74fca6a42863ffacaf7ba6f1936a9f228950f657:

   Linux 2.6.31 (2009-09-09 15:13:59 -0700)

are available in the git repository at:
   git://git.kernel.org/pub/scm/linux/kernel/git/jeremy/xen.git upstream/netfront

Dongxiao Xu (1):
       xen/netfront: Use smart polling instead of event notification.

Ian Campbell (2):
       xen/rings: make protocol specific usage of shared sring explicit
       xen/netfront: make protocol specific usage of shared sring explicit

  drivers/net/xen-netfront.c      |  114 ++++++++++++++++++++++++++++++++++++++-
  include/xen/interface/io/ring.h |   11 ++++-
  2 files changed, 122 insertions(+), 3 deletions(-)
