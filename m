From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net,stable 0/3] qmi_wwan: working around 3 serious firmware bugs
Date: Fri, 19 Apr 2013 00:57:08 +0200
Message-ID: <1366325831-13727-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:40241 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754984Ab3DRW5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 18:57:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds workarounds for 3 different firmware bugs, each
preventing the affected devices from working at all. I therefore
humbly request that these fixes go to stable-3.8 (if still
maintained) and 3.9 (either via net if still possible, or via
stable if not).

All 3 workarounds are applied to all devices supported by the driver.
Adding quirks for specific devices was considered as an alternative,
but was rejected because we have too little information about the
exact distribution of the buggy firmwares. All we know is that the
same bug shows up in devices from at least 3 different, and presumably
independent, vendors.

The workarounds have instead been designed to automatically apply
when necessary, and to have as little impact as possible on unaffected
devices.  The series has been tested on a number of devices both with
and without these bugs.

The series should apply cleanly to net/master, net-next/master and
stable/linux-3.8.y


Thanks,
Bj=C3=B8rn


Bj=C3=B8rn Mork (3):
  net: qmi_wwan: fixup missing ethernet header (firmware bug
    workaround)
  net: qmi_wwan: fixup destination address (firmware bug workaround)
  net: qmi_wwan: prevent duplicate mac address on link (firmware bug
    workaround)

 drivers/net/usb/qmi_wwan.c |  104 ++++++++++++++++++++++++++++++++++++=
++++++++
 1 file changed, 104 insertions(+)

--=20
1.7.10.4
