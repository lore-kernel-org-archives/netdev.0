From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH 0/2] New LSM hooks for the TUN driver
Date: Fri, 28 Aug 2009 18:12:36 -0400
Message-ID: <20090828220400.3900.64377.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:38128 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753002AbZH1WMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 18:12:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the third, and hopefully final, version of the new LSM TUN hooks.  This
version incorporates all outstanding feedback as well as my sign-off and ACKs
from both Eric and Serge (see patches).  However, the patches are still missing
an ACK from netdev - I haven't heard any objections but I'm not certain anyone
from netdev has really taken a look yet.

Dave and James - these patches once again straddle that line between networking
and security; while James has usually ushered these types of patches upstream
in the past I'll let you two fight it out again for the honors (assuming you
are both okay with the patches).

The patches can also be found in git form here:

 * git://git.infradead.org/users/pcmoore/lblnet-2.6_next

Thanks.

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
