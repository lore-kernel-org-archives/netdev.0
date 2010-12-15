From: Mike Waychison <mikew@google.com>
Subject: Re: [PATCH v3 14/22] netpoll: Move target code into netpoll_targets.c
Date: Tue, 14 Dec 2010 16:07:20 -0800
Message-ID: <AANLkTimxv8kO5vQfL-dEhCgkU7YX+qYUWONqyt1uj45y@mail.gmail.com>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com> <20101214213010.17022.54049.stgit@mike.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: adurbin@google.com, linux-kernel@vger.kernel.org,
	chavey@google.com, Greg KH <greg@kroah.com>,
	netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	akpm@linux-foundation.org, linux-api@vger.kernel.org
To: simon.kagstrom@netinsight.net, davem@davemloft.net,
	nhorman@tuxdriver.com, Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101214213010.17022.54049.stgit@mike.mtv.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ugh.  I just realized that I was missing a MODULE_LICENSE("GPL"); for
this new module, otherwise module load fails to find the link for
cancel_work_sync.

---
netpoll: Add missing module license for netpoll_targets

Add a missing module license declaration to netpoll_targets that allows
it to use exported symbols (cancel_work_sync).

Signed-off-by: Mike Waychison <mikew@google.com>

diff --git a/net/core/netpoll_targets.c b/net/core/netpoll_targets.c
index 5fc84f8c..0887268 100644
--- a/net/core/netpoll_targets.c
+++ b/net/core/netpoll_targets.c
@@ -747,3 +747,4 @@ void unregister_netpoll_targets(struct netpoll_targets *nts)
 }
 EXPORT_SYMBOL_GPL(unregister_netpoll_targets);

+MODULE_LICENSE("GPL");
