From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH linux v3 0/1] Optimize network interfaces creation
Date: Tue,  7 Oct 2014 11:02:38 +0200
Message-ID: <1412672559-5256-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20141006.181448.1696747135961247651.davem@davemloft.net>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	akpm@linux-foundation.org, adobriyan@gmail.com,
	rui.xiang@huawei.com, viro@zeniv.linux.org.uk, oleg@redhat.com,
	gorcunov@openvz.org, kirill.shutemov@linux.intel.com,
	grant.likely@secretlab.ca, tytso@mit.edu
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141006.181448.1696747135961247651.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a lot of netdevices are created, one of the bottleneck is the creation
of proc entries. This serie aims to accelerate this part.

I'm not sure against which tree this patch should be done. I've done it against
linux.git.

v2 -> v3
 - restore credit to Thierry Herbelot for the initial idea.

RFCv1 -> v2
 - use a red-black tree instead of a hash list

 fs/proc/generic.c  | 164 ++++++++++++++++++++++++++++++++++-------------------
 fs/proc/internal.h |  11 ++--
 fs/proc/proc_net.c |   1 +
 fs/proc/root.c     |   1 +
 4 files changed, 113 insertions(+), 64 deletions(-)

Comments are welcome.

Regards,
Nicolas
