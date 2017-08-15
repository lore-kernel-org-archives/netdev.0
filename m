From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/5] net/9p: Fine-tuning for some function implementations
Date: Tue, 15 Aug 2017 13:56:37 +0200
Message-ID: <22a44d7c-cdb9-e206-4b2c-56e38cbf0de1@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Latchesar Ionkov <lucho@ionkov.net>,
        Ron Minnich <rminnich@sandia.gov>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 15 Aug 2017 13:43:21 +0200

Some update suggestions were taken into account
from static source code analysis.

Markus Elfring (5):
  Delete an error message for a failed memory allocation in five functions
  Improve 19 size determinations
  Add a jump target in p9_client_walk()
  Adjust a jump target in p9_client_attach()
  Delete an unnecessary variable initialisation in p9_client_attach()

 net/9p/client.c       | 51 +++++++++++++++++++++------------------------------
 net/9p/protocol.c     |  6 +++---
 net/9p/trans_fd.c     | 16 +++++++---------
 net/9p/trans_rdma.c   |  8 +++-----
 net/9p/trans_virtio.c |  6 ++----
 net/9p/util.c         |  2 +-
 6 files changed, 37 insertions(+), 52 deletions(-)

-- 
2.14.0
