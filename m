From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 06/10] sysctl: Remove broken sunrpc debug binary sysctls
Date: Thu, 09 Aug 2007 18:58:46 -0600
Message-ID: <m1r6mc8at5.fsf_-_@ebiederm.dsl.xmission.com>
References: <20070726164518.GB16937@localhost.sw.ru>
	<m13azbulhf.fsf@ebiederm.dsl.xmission.com>
	<20070727145235.GC6924@localhost.sw.ru>
	<20070806124530.GD6634@localhost.sw.ru>
	<m1tzr8a3ms.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ps1wa3kf.fsf_-_@ebiederm.dsl.xmission.com>
	<m1hcn8a2rq.fsf_-_@ebiederm.dsl.xmission.com>
	<m1d4xw9psl.fsf_-_@ebiederm.dsl.xmission.com>
	<m18x8k9ppv.fsf_-_@ebiederm.dsl.xmission.com>
	<m14pj89pmt.fsf_-_@ebiederm.dsl.xmission.com>
	<m1zm108axi.fsf_-_@ebiederm.dsl.xmission.com>
	<m1vebo8avf.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@sw.ru>,
	<netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	trond.myklebust@fys.uio.no
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:36219 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756889AbXHJBAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 21:00:36 -0400
In-Reply-To: <m1vebo8avf.fsf_-_@ebiederm.dsl.xmission.com> (Eric
	W. Biederman's message of "Thu, 09 Aug 2007 18:57:24 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From ddf280c9de903f1fb5d4ecf9c68df0c479d7c7d2 Mon Sep 17 00:00:00 2001
From: Eric W. Biederman <ebiederm@xmission.com>
Date: Thu, 9 Aug 2007 16:00:00 -0600
Subject: 

This is debug code so no need to support binary sysctl,
and the binary sysctls as they were written were not
consistent with what showed up in /proc so remove
the binary sysctl support.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/sunrpc/sysctl.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index 738db32..864b541 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -114,7 +114,6 @@ done:
 
 static ctl_table debug_table[] = {
 	{
-		.ctl_name	= CTL_RPCDEBUG,
 		.procname	= "rpc_debug",
 		.data		= &rpc_debug,
 		.maxlen		= sizeof(int),
@@ -122,7 +121,6 @@ static ctl_table debug_table[] = {
 		.proc_handler	= &proc_dodebug
 	},
 	{
-		.ctl_name	= CTL_NFSDEBUG,
 		.procname	= "nfs_debug",
 		.data		= &nfs_debug,
 		.maxlen		= sizeof(int),
@@ -130,7 +128,6 @@ static ctl_table debug_table[] = {
 		.proc_handler	= &proc_dodebug
 	},
 	{
-		.ctl_name	= CTL_NFSDDEBUG,
 		.procname	= "nfsd_debug",
 		.data		= &nfsd_debug,
 		.maxlen		= sizeof(int),
@@ -138,7 +135,6 @@ static ctl_table debug_table[] = {
 		.proc_handler	= &proc_dodebug
 	},
 	{
-		.ctl_name	= CTL_NLMDEBUG,
 		.procname	= "nlm_debug",
 		.data		= &nlm_debug,
 		.maxlen		= sizeof(int),
-- 
1.5.1.1.181.g2de0

