From: Richard Yao <ryao@gentoo.org>
Subject: [PATCH] 9p/trans_virtio.c: Fix broken zero-copy on vmalloc() buffers (second submission)
Date: Thu, 30 Jan 2014 13:02:47 -0500
Message-ID: <1391104968-10258-1-git-send-email-ryao@gentoo.org>
Cc: Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	V9FS Develooper Mailing List
	<v9fs-developer@lists.sourceforge.net>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Gentoo Kernel Team <kernel@gentoo.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	Will Deacon <will.deacon@arm.com>,
	Christopher Covington <cov@codeaurora.org>,
	Brian Behlendorf <behlendorf1@llnl.gov>,
	Matthew Thode <mthode@mthode.org>,
	Richard Yao <ryao@gentoo.org>
To: Eric Van Hensbergen <ericvh@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is my first real patch submission, which I sent out in December.
Unfortunately, I sent it to only a subset of the correct people. Time passed,
Greg Koah-Hartman was kind enough to give me some pointers and I am now sending
it back out to the correct people. My apologies to anyone who was bit by this
issue because it was not sent to the correct people sooner.

Richard Yao (1):
  9p/trans_virtio.c: Fix broken zero-copy on vmalloc() buffers

 net/9p/trans_virtio.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

-- 
1.8.3.2
