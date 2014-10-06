From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH linux v2 0/1] Optimize network interfaces creation
Date: Mon,  6 Oct 2014 16:30:33 +0200
Message-ID: <1412605834-4417-1-git-send-email-nicolas.dichtel@6wind.com>
References: <542EA009.4060009@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	akpm@linux-foundation.org, adobriyan@gmail.com,
	rui.xiang@huawei.com, viro@zeniv.linux.org.uk, oleg@redhat.com,
	gorcunov@openvz.org, kirill.shutemov@linux.intel.com,
	grant.likely@secretlab.ca, tytso@mit.edu
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <542EA009.4060009@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a lot of netdevices are created, one of the bottleneck is the creation
of proc entries. This serie aims to accelerate this part.

I'm not sure against which tree this patch should be done. I've done it against
linux.git.

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
