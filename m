From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [iproute2 0/2][pull request] Intel Wired LAN Driver Updates 2017-10-26
Date: Thu, 26 Oct 2017 10:17:47 -0700
Message-ID: <20171026171749.45134-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35393 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932345AbdJZRSK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 13:18:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains the iproute2 changes needed to support the new
Time Sensitive Networking (TSN) feature which was submitted to netdev.

The following are changes since commit 35f2a7639dca422db7c237a007d09332de95f9a7:
  tc/actions: introduce support for jump action
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/iproute2 master

Vinicius Costa Gomes (2):
  tc: Add support for the CBS qdisc
  man: Add initial manpage for tc-cbs(8)

 man/man8/tc-cbs.8 | 112 ++++++++++++++++++++++++++++++++++++++++++
 tc/Makefile       |   1 +
 tc/q_cbs.c        | 142 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 255 insertions(+)
 create mode 100644 man/man8/tc-cbs.8
 create mode 100644 tc/q_cbs.c

-- 
2.14.2
