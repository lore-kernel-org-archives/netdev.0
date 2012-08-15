From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [RFC PATCH 3/5] net: new protocol operation fbind() introduced
Date: Wed, 15 Aug 2012 20:22:14 +0400
Message-ID: <20120815162214.7598.44496.stgit@localhost.localdomain>
References: <20120815161141.7598.16682.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: thierry.reding@avionic-design.de, bfields@redhat.com,
	eric.dumazet@gmail.com, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, x86@kernel.org,
	linux-kernel@vger.kernel.org, paul.gortmaker@windriver.com,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	akpm@linux-foundation.org, tim.c.chen@linux.intel.com,
	devel@openvz.org, ebiederm@xmission.com
To: tglx@linutronix.de, mingo@redhat.com, davem@davemloft.net,
	hpa@zytor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120815161141.7598.16682.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This operation is used to bind socket to specified file.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 include/linux/net.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index e9ac2df..843cb75 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -157,6 +157,7 @@ struct kiocb;
 struct sockaddr;
 struct msghdr;
 struct module;
+struct path;
 
 struct proto_ops {
 	int		family;
@@ -165,6 +166,7 @@ struct proto_ops {
 	int		(*bind)	     (struct socket *sock,
 				      struct sockaddr *myaddr,
 				      int sockaddr_len);
+	int		(*fbind)     (struct file *file, struct socket *sock);
 	int		(*connect)   (struct socket *sock,
 				      struct sockaddr *vaddr,
 				      int sockaddr_len, int flags);
