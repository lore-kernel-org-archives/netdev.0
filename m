From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v2 0/4] SUNRPC: service release in network namespace context
Date: Tue, 31 Jan 2012 14:08:50 +0400
Message-ID: <20120131100625.4342.34539.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, bfields@fieldses.org,
	davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v2: Added comment to BUG_ON's in svc_destroy() to make code looks clearer.

This patch set is the final step towards to making LockD network namespace
aware.
I can't prove, that this patch set is enough for NFSd (just haven't try), by
Lockd works fine and patches for it will be send soon.

The following series consists of:

---

Stanislav Kinsbursky (4):
      SUNRPC: clear svc pools lists helper introduced
      SUNRPC: clear svc transports lists helper introduced
      SUNRPC: service destruction in network namespace context
      SUNRPC: service shutdown function in network namespace context introduced


 include/linux/sunrpc/svcsock.h |    2 +-
 net/sunrpc/svc.c               |   38 ++++++++++++++++++++++++----------
 net/sunrpc/svc_xprt.c          |   45 ++++++++++++++++++++++++++++------------
 3 files changed, 59 insertions(+), 26 deletions(-)
