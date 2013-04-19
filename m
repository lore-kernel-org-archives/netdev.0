From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 0/8] qlcnic: SR-IOV enhancements
Date: Fri, 19 Apr 2013 13:01:07 -0400
Message-ID: <1366390875-24570-1-git-send-email-rajesh.borundia@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:42477 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751211Ab3DSRZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 13:25:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* "qlcnic: Change 82xx adapter VLAN id endian type".
  - Adapter requires VLAN id in little endian. VLAN id was being
    converted to __le16 and then passed as a parameter. Pass VLAN id
    as u16 and then use cpu_to_le16 at appropriate places. It is 
    appropriate for net-next as SR-IOV patches have a dependency on it.
* "qlcnic: Fix loopback test for SR-IOV PF".
  - It is appropriate for net-next as change is needed for SRIOV PF
    only.
* Remaining patches add enhancements to SR-IOV functionality like
  - FLR handling
  - Adapter reset recovery handling
  - iproute2 tool support for configuring MAC address, Tx rate and
    VLAN id.
  - Mailbox polling support for SR-IOV PF in case mailbox interrupts
    are disabled.

Please consider it for net-next.

Thanks,
Rajesh

Rajesh Borundia (8):
  qlcnic: Change 82xx adapter VLAN id endian type.
  qlcnic: VF FLR implementation.
  qlcnic: VF reset recovery implementation.
  qlcnic: Support MAC address, Tx rate config.
  qlcnic: Support VLAN id config.
  qlcnic: Fix loopback test for SR-IOV PF.
  qlcnic: Support polling for mailbox events.
  qlcnic: Update version to 5.2.41
