From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v2 0/2] New LSM hooks for the TUN driver
Date: Mon, 10 Aug 2009 13:28:37 -0400
Message-ID: <20090810172238.7946.34247.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Second draft of the new TUN driver LSM hooks, thanks to everyone who sent
comments, especially Serge Hallyn and Eric Paris.  Nothing substantial has
changed in this version with respect to the hooks, just lots of little
changes to cleanup the patches and ensure they build on various different
configurations.  I still need to do more testing but barring any issues this
should be the code that I sign-off for inclusion.

In the meantime I've populated the lblnet-2.6_next tree with these patches so
feel free to pull from there if you want to play with the code.

 * git://git.infradead.org/users/pcmoore/lblnet-2.6_next

---

Paul Moore (2):
      selinux: Support for the new TUN LSM hooks
      lsm: Add hooks to the TUN driver


 drivers/net/tun.c                          |   22 +++++++---
 include/linux/security.h                   |   31 ++++++++++++++
 security/capability.c                      |   19 +++++++++
 security/security.c                        |   18 ++++++++
 security/selinux/hooks.c                   |   60 +++++++++++++++++++++++++++-
 security/selinux/include/av_inherit.h      |    1 
 security/selinux/include/av_permissions.h  |   22 ++++++++++
 security/selinux/include/class_to_string.h |    1 
 security/selinux/include/flask.h           |    1 
 9 files changed, 166 insertions(+), 9 deletions(-)

