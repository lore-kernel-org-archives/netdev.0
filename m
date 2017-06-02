From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 0/4] qed: Enhance storage APIs
Date: Fri, 2 Jun 2017 08:58:29 +0300
Message-ID: <20170602055833.21814-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-scsi@vger.kernel.org>, <nilesh.javali@cavium.com>,
        <chad.dupuis@cavium.com>, <saurav.kashyap@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is intended to add additional information and features
to the API between qed and its storage protocol drivers [qedi, qedf].

Patch #2 adds some information stored on device such as wwpn & wwnn
to allow qedf utilize it; #1 fixes an issue with the reading of those
values [which were unused until now].

Patch #3 would allow the protocol drivers access to images on persistent
storage which is a prerequirement for adding boot from SAN support.

Patch #4 adds infrastrucutre to a future feature for qedi.

Dave,

Please consider applying this series to 'net-next'.

Thanks,
Yuval

Yuval Mintz (4):
  qed: Correct order of wwnn and wwpn
  qed: Share additional information with qedf
  qed: Support NVM-image reading API
  qed: Add support for changing iSCSI mac

 drivers/net/ethernet/qlogic/qed/qed_dev.c   |  8 ++-
 drivers/net/ethernet/qlogic/qed/qed_fcoe.c  | 14 +++++
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c | 66 ++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_main.c  | 18 ++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c   | 97 +++++++++++++++++++++++++++--
 drivers/net/ethernet/qlogic/qed/qed_mcp.h   | 21 +++++++
 drivers/net/ethernet/qlogic/qed/qed_sp.h    |  1 +
 include/linux/qed/qed_fcoe_if.h             |  5 ++
 include/linux/qed/qed_if.h                  | 20 ++++++
 include/linux/qed/qed_iscsi_if.h            |  7 +++
 10 files changed, 252 insertions(+), 5 deletions(-)

-- 
2.9.4
