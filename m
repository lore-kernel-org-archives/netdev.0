From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [GIT PULL] namespaces fixes for 3.14-rcX
Date: Sun, 09 Mar 2014 20:06:43 -0700
Message-ID: <87bnxesqf0.fsf_-_@xmission.com>
References: <874n3ir0uw.fsf_-_@xmission.com> <87mwhaplo4.fsf_-_@xmission.com>
	<20140304133004.b565820f60f595a48e621e58@linux-foundation.org>
	<20140304.165122.445822929490466603.davem@davemloft.net>
	<87mwh5d1tf.fsf@xmission.com>
	<20140304145037.d46ee775d293dd1ad60aa8e3@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, rgb@redhat.com,
	eparis@redhat.com, linux-audit@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140304145037.d46ee775d293dd1ad60aa8e3@linux-foundation.org>
	(Andrew Morton's message of "Tue, 4 Mar 2014 14:50:37 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: d211f177b28ec070c25b3d0b960aa55f352f731f audit: Update kdoc for audit_send_reply and audit_list_rules_send

Starting with 3.14-rc1 the audit code is faulty (think oopses and races)
with respect to how it computes the network namespace of which socket to
reply to, and I happened to notice by chance when reading through the
code.

My efforts to get these fixes noticed by people who care about audit
seem to have landed on deaf ears, so since these are namespace related I
have put them in my tree.

My testing and the automated build bots don't find any problems with
these fixes.

Eric W. Biederman (3):
      audit: Use struct net not pid_t to remember the network namespce to reply in
      audit: Send replies in the proper network namespace.
      audit: Update kdoc for audit_send_reply and audit_list_rules_send

 include/linux/audit.h |    3 ++-
 kernel/audit.c        |   31 ++++++++++++++++---------------
 kernel/audit.h        |    2 +-
 kernel/auditfilter.c  |   10 +++++++---
 4 files changed, 26 insertions(+), 20 deletions(-)

Eric
