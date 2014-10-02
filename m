From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH linux 0/2] Optimize network interfaces creation
Date: Thu,  2 Oct 2014 17:24:59 +0200
Message-ID: <1412263501-6572-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20131003.150947.2179820478039260398.davem@davemloft.net>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	akpm@linux-foundation.org, adobriyan@gmail.com,
	rui.xiang@huawei.com, viro@zeniv.linux.org.uk, oleg@redhat.com,
	gorcunov@openvz.org, kirill.shutemov@linux.intel.com,
	grant.likely@secretlab.ca, tytso@mit.edu
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131003.150947.2179820478039260398.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a lot of netdevices are created, one of the bottleneck is the creation
of proc entries. This serie aims to accelerate this part.

The first patch only prepares the second one.

I'm not sure against which tree this patch should be done. I've done it against
linux.git.

 fs/proc/generic.c  | 100 +++++++++++++++++++++++++++++++++++++++++------------
 fs/proc/internal.h |  49 +++++++++++++++++++++++---
 fs/proc/proc_net.c |   8 +++++
 fs/proc/root.c     |   5 +++
 4 files changed, 135 insertions(+), 27 deletions(-)

Comments are welcome.

Regards,
Nicolas
