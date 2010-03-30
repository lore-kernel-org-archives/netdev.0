From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 7/6] sysfs: Remove double free sysfs_get_sb
Date: Tue, 30 Mar 2010 16:50:26 -0700
Message-ID: <m1zl1pbc8t.fsf_-_@fess.ebiederm.org>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
	<1269973889-25260-1-git-send-email-ebiederm@xmission.com>
	<1269977012.2048.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org, Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:45202 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757276Ab0C3Xug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 19:50:36 -0400
In-Reply-To: <1269977012.2048.0.camel@edumazet-laptop> (Eric Dumazet's message of "Tue\, 30 Mar 2010 21\:23\:32 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 fs/sysfs/mount.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index 13bd0ba..bbba090 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -121,7 +121,6 @@ static int sysfs_get_sb(struct file_system_type *fs_type,
 	if (IS_ERR(sb) || sb->s_fs_info != info)
 		kfree(info);
 	if (IS_ERR(sb)) {
-		kfree(info);
 		error = PTR_ERR(sb);
 		goto out;
 	}
-- 
1.6.5.2.143.g8cc62

