From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 0/1] net: Add support for rmnet_data driver
Date: Thu, 23 Feb 2017 20:30:53 -0700
Message-ID: <1487907054-15129-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net, fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:49476 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751971AbdBXDbW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 22:31:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the rmnet_data driver which is required to
support recent chipsets using Qualcomm Technologies, Inc. modems. The data
from hardware follows the multiplexing and aggregation protocol (MAP).

This driver can be used to register onto any physical network device in
IP mode. Physical transports include USB, HSIC, PCIe and IP accelerator.

rmnet_data driver helps to decode these packets and queue them to network
stack (and encode and transmit it to the physical device).

--
This is the same as the RFC patch with some minor fixes for issues
reported by kbuild test robot.

Subash Abhinov Kasiviswanathan (1):
  net: rmnet_data: Initial implementation

 Documentation/networking/rmnet_data.txt |   82 +++
 include/uapi/linux/Kbuild               |    1 +
 include/uapi/linux/if_arp.h             |    1 +
 include/uapi/linux/if_ether.h           |    3 +-
 include/uapi/linux/rmnet_data.h         |  416 +++++++++++
 net/Kconfig                             |    1 +
 net/Makefile                            |    1 +
 net/rmnet_data/Kconfig                  |   21 +
 net/rmnet_data/Makefile                 |   14 +
 net/rmnet_data/rmnet_data_config.c      | 1145 +++++++++++++++++++++++++++++++
 net/rmnet_data/rmnet_data_config.h      |  123 ++++
 net/rmnet_data/rmnet_data_handlers.c    |  559 +++++++++++++++
 net/rmnet_data/rmnet_data_handlers.h    |   24 +
 net/rmnet_data/rmnet_data_main.c        |   60 ++
 net/rmnet_data/rmnet_data_private.h     |   76 ++
 net/rmnet_data/rmnet_data_stats.c       |   86 +++
 net/rmnet_data/rmnet_data_stats.h       |   61 ++
 net/rmnet_data/rmnet_data_trace.h       |  183 +++++
 net/rmnet_data/rmnet_data_vnd.c         |  596 ++++++++++++++++
 net/rmnet_data/rmnet_data_vnd.h         |   40 ++
 net/rmnet_data/rmnet_map.h              |  148 ++++
 net/rmnet_data/rmnet_map_command.c      |  177 +++++
 net/rmnet_data/rmnet_map_data.c         |  154 +++++
 23 files changed, 3971 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/networking/rmnet_data.txt
 create mode 100644 include/uapi/linux/rmnet_data.h
 create mode 100644 net/rmnet_data/Kconfig
 create mode 100644 net/rmnet_data/Makefile
 create mode 100644 net/rmnet_data/rmnet_data_config.c
 create mode 100644 net/rmnet_data/rmnet_data_config.h
 create mode 100644 net/rmnet_data/rmnet_data_handlers.c
 create mode 100644 net/rmnet_data/rmnet_data_handlers.h
 create mode 100644 net/rmnet_data/rmnet_data_main.c
 create mode 100644 net/rmnet_data/rmnet_data_private.h
 create mode 100644 net/rmnet_data/rmnet_data_stats.c
 create mode 100644 net/rmnet_data/rmnet_data_stats.h
 create mode 100644 net/rmnet_data/rmnet_data_trace.h
 create mode 100644 net/rmnet_data/rmnet_data_vnd.c
 create mode 100644 net/rmnet_data/rmnet_data_vnd.h
 create mode 100644 net/rmnet_data/rmnet_map.h
 create mode 100644 net/rmnet_data/rmnet_map_command.c
 create mode 100644 net/rmnet_data/rmnet_map_data.c

-- 
1.9.1
