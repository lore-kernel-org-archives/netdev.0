From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v5 01/10] ipc: remove forced assignment of selected message
Date: Wed, 19 Sep 2012 20:05:31 +0400
Message-ID: <20120919160531.11254.48182.stgit@localhost6.localdomain6>
References: <20120919160430.11254.86848.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, a.p.zijlstra@chello.nl,
	netdev@vger.kernel.org, will.deacon@arm.com,
	linux-kernel@vger.kernel.org, cmetcalf@tilera.com,
	jmorris@namei.org, linux-driver@qlogic.com,
	linux-security-module@vger.kernel.org, hughd@google.com,
	ron.mercer@qlogic.com, viro@zeniv.linux.org.uk,
	james.l.morris@oracle.com, catalin.marinas@arm.com,
	casey@schaufler-ca.com, eparis@parisplace.org, sds@tycho.nsa.gov,
	jitendra.kalsaria@qlogic.com, devel@openvz.org
To: akpm@linux-foundation.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20120919160430.11254.86848.stgit@localhost6.localdomain6>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a cleanup patch. The assignment is redundant.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 ipc/msg.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/ipc/msg.c b/ipc/msg.c
index 7385de2..f3bfbb8 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -787,7 +787,6 @@ long do_msgrcv(int msqid, long *pmtype, void __user *mtext,
 			    !security_msg_queue_msgrcv(msq, walk_msg, current,
 						       msgtyp, mode)) {
 
-				msg = walk_msg;
 				if (mode == SEARCH_LESSEQUAL &&
 						walk_msg->m_type != 1) {
 					msg = walk_msg;

