From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 0/2] Fix some minor issues in igb driver
Date: Thu, 05 Mar 2015 11:24:53 -0800
Message-ID: <20150305192031.22228.75375.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: e1000-devel@lists.sourceforge.net, jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56563 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751878AbbCETZE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 14:25:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fix a warning I have been seeing from the igb driver when
building the net-next kernel on my Fedora 20 system.

The 'pin' patch contains the fix for the warning, the other is a minor
cleanup for the fact that the function was placing several arrays onto =
the
stack when it would have been much more efficient to just store them as=
=20
static const arrays.

---

Alexander Duyck (2):
      igb: Fix warning =E2=80=98pin=E2=80=99 may be used uninitialized
      igb: Make arrays on stack static const to avoid reallocation


 drivers/net/ethernet/intel/igb/igb_ptp.c |   26 +++++++++++++---------=
----
 1 file changed, 13 insertions(+), 13 deletions(-)

--
