From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v6 01/10] ipc: remove forced assignment of selected message
Date: Mon, 15 Oct 2012 19:59:41 +0400
Message-ID: <20121015155941.28348.88481.stgit@localhost.localdomain>
References: <20121015155800.28348.23561.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: catalin.marinas@arm.com, will.deacon@arm.com, dhowells@redhat.com,
	manfred@colorfullife.com, hughd@google.com, jmorris@namei.org,
	mtk.manpages@gmail.com, kosaki.motohiro@jp.fujitsu.com,
	paulmck@linux.vnet.ibm.com, sds@tycho.nsa.gov, devel@openvz.org,
	a.p.zijlstra@chello.nl, cmetcalf@tilera.com,
	linux-driver@qlogic.com, ron.mercer@qlogic.com,
	viro@zeniv.linux.org.uk, eparis@parisplace.org, tglx@linutronix.de,
	jitendra.kalsaria@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, ebiederm@xmission.com,
	casey@schaufler-ca.com
To: akpm@linux-foundation.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20121015155800.28348.23561.stgit@localhost.localdomain>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a cleanup patch. The assignment is redundant.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 ipc/msg.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/ipc/msg.c b/ipc/msg.c
index a71af5a..2f272fa 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -793,12 +793,9 @@ long do_msgrcv(int msqid, long *pmtype, void __user *mtext,
 				msg = walk_msg;
 				if (mode == SEARCH_LESSEQUAL &&
 						walk_msg->m_type != 1) {
-					msg = walk_msg;
 					msgtyp = walk_msg->m_type - 1;
-				} else {
-					msg = walk_msg;
+				} else
 					break;
-				}
 			}
 			tmp = tmp->next;
 		}

