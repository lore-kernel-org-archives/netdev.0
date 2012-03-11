From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 0/2] NFS: blocklayout PipeFS conteinerization fixes
Date: Sun, 11 Mar 2012 18:20:13 +0400
Message-ID: <20120311141528.17962.83828.stgit@localhost6.localdomain6>
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

This patch set moves global wait queue and message to per-net data structure.

---

Stanislav Kinsbursky (2):
      NFS: replace global bl_mount_reply with per-net one
      NFS: replace global bl_wq with per-net one


 fs/nfs/blocklayout/blocklayout.c    |    4 +--
 fs/nfs/blocklayout/blocklayout.h    |    8 +++----
 fs/nfs/blocklayout/blocklayoutdev.c |   41 ++++++++++++++++++++---------------
 fs/nfs/blocklayout/blocklayoutdm.c  |   26 ++++++++++++----------
 fs/nfs/netns.h                      |    7 ++++++
 5 files changed, 48 insertions(+), 38 deletions(-)
