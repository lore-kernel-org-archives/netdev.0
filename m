From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 00/13] s390: qeth patches
Date: Wed, 11 Jan 2017 12:55:47 +0100
Message-ID: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        stable@vger.kernel.org, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are several fixes for the s390 qeth driver, built for net-next.

Thanks,
Ursula

Julian Wiedmann (8):
  s390/qeth: Allow reading hsuid from sysfs while card is DOWN
  s390/qeth: Remove unused define QETH_IP_HEADER_SIZE
  s390/qeth: drop unused parameter from qeth_l2_del_all_macs()
  s390/qeth: when setting group MAC, don't convert return code twice
  s390/qeth: consolidate errno translation for MAC management
  s390/qeth: extract qeth_l2_remove_mac()
  s390/qeth: shuffle MAC management functions around
  s390/qeth: issue STARTLAN as first IPA command

Thomas Richter (3):
  s390/qeth: rework RX/TX checksum offload command to use call back
    functions
  s390/qeth: test RX/TX checksum offload reply from hardware
  s390/qeth: display warning for OSA3 RX/TX checksum offloading

Ursula Braun (2):
  s390/qeth: fix retrieval of vipa and proxy-arp addresses
  s390/qeth: remove OSN-devices

 drivers/s390/net/qeth_core.h      |  33 ---
 drivers/s390/net/qeth_core_main.c | 188 +++++++++-------
 drivers/s390/net/qeth_core_mpc.c  |   3 -
 drivers/s390/net/qeth_core_mpc.h  |  27 ++-
 drivers/s390/net/qeth_core_sys.c  |  17 --
 drivers/s390/net/qeth_l2_main.c   | 456 +++++++++++---------------------------
 drivers/s390/net/qeth_l3_main.c   |  15 --
 drivers/s390/net/qeth_l3_sys.c    |  33 ++-
 8 files changed, 268 insertions(+), 504 deletions(-)

-- 
2.8.4
