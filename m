From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH 0/2] Fix some multiqueue TUN problems
Date: Mon, 14 Jan 2013 12:12:06 -0500
Message-ID: <20130114170837.31874.78897.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No significant changes to this patchset since the last posting, just a
slight merge with the recent changes in tun_set_queue() and some
Acked-by and Tested-by additions.  I believe all the concerns have been
addressed and this patch is ready for merging.

Dave, I think it makes the most sense for this to get pulled in via the
netdev tree but if you think otherwise let me know and I'll go bug
James and Eric.

-Paul

---

Paul Moore (2):
      selinux: add the "attach_queue" permission to the "tun_socket" class
      tun: fix LSM/SELinux labeling of tun/tap devices


 drivers/net/tun.c                   |   23 +++++++++++---
 include/linux/security.h            |   59 +++++++++++++++++++++++++++--------
 security/capability.c               |   24 ++++++++++++--
 security/security.c                 |   28 ++++++++++++++---
 security/selinux/hooks.c            |   50 +++++++++++++++++++++++-------
 security/selinux/include/classmap.h |    2 +
 security/selinux/include/objsec.h   |    4 ++
 7 files changed, 152 insertions(+), 38 deletions(-)
