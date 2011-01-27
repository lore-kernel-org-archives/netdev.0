From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH RESEND 0/4] Fix kconfig breakage wrt to CONFIGFS_FS
Date: Thu, 27 Jan 2011 11:10:26 -0800
Message-ID: <1296155430-3796-1-git-send-email-nab@linux-iscsi.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>, Joel Becker <jlbec@evilplan.org>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Americo Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Bellinger <nab@linux-iscsi.org>

Hi Linus,

The following four patches are to address recent Kconfig CONFIGFS_FS ->
'select SYSFS' change for GFS2_FS, and 'depends && SYSFS && CONFIGFS_FS'
breakage for NETCONSOLE_DYNAMIC, DLM, and OCFS2_FS in .38-rc2.

Please review and consider pulling from:

  git://git.kernel.org/pub/scm/linux/kernel/git/nab/scsi-post-merge-2.6.git for-linus-v2

currently against the latest linux-2.6.git/master HEAD:

  commit 6fb1b304255efc5c4c93874ac8c066272e257e28
  Merge: ac751ef 409550f
  Author: Linus Torvalds <torvalds@linux-foundation.org>
  Date:   Wed Jan 26 16:31:44 2011 +1000

      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/dtor/input

Thanks,

Signed-off-by: Nicholas A. Bellinger <nab@linux-iscsi.org>

Nicholas Bellinger (4):
  gfs2: Remove 'select SYSFS ...' from Kconfig
  net: Make NETCONSOLE_DYNAMIC use select CONFIGFS_FS
  dlm: Make DLM use select CONFIGFS_FS
  ocfs2: Make OCFS2_FS use select CONFIGFS_FS

 drivers/net/Kconfig |    3 ++-
 fs/dlm/Kconfig      |    4 ++--
 fs/gfs2/Kconfig     |    1 -
 fs/ocfs2/Kconfig    |    3 ++-
 4 files changed, 6 insertions(+), 5 deletions(-)

-- 
1.7.3.5
