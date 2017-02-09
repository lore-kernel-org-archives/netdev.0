From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [RFC PATCH net-next 0/1] net: Add support for rmnet_data driver
Date: Wed,  8 Feb 2017 18:36:44 -0700
Message-ID: <1486604205-28355-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:34042 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751459AbdBICV1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 21:21:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the rmnet_data driver which is required to
support recent chipsets using Qualcomm Technologies, Inc. modems. The data
from hardware follows the multiplexing and aggregation protocol (MAP).

This driver can be used to register onto any physical network device in
IP mode. Physical transports include USB, HSIC, PCIe and IP accelerator.

rmnet_data driver helps to decode these packets and queue them to network
stack (and encode and transmit it to the physical device).

Subash Abhinov Kasiviswanathan (1):
  net: rmnet_data: Initial implementation

 Documentation/networking/rmnet_data.txt |   82 +++
 include/uapi/linux/Kbuild               |    2 +
 include/uapi/linux/if_arp.h             |    1 +
 include/uapi/linux/if_ether.h           |    3 +-
 include/uapi/linux/rmnet_data.h         |  416 +++++++++++
 net/Kconfig                             |    1 +
 net/Makefile                            |    1 +
 net/rmnet_data/Kconfig                  |   21 +
 net/rmnet_data/Makefile                 |   14 +
 net/rmnet_data/rmnet_data_config.c      | 1149 +++++++++++++++++++++++++++++++
 net/rmnet_data/rmnet_data_config.h      |  123 ++++
 net/rmnet_data/rmnet_data_handlers.c    |  560 +++++++++++++++
 net/rmnet_data/rmnet_data_handlers.h    |   24 +
 net/rmnet_data/rmnet_data_main.c        |   60 ++
 net/rmnet_data/rmnet_data_private.h     |   76 ++
 net/rmnet_data/rmnet_data_stats.c       |   86 +++
 net/rmnet_data/rmnet_data_stats.h       |   61 ++
 net/rmnet_data/rmnet_data_trace.h       |  183 +++++
 net/rmnet_data/rmnet_data_vnd.c         |  602 ++++++++++++++++
 net/rmnet_data/rmnet_data_vnd.h         |   40 ++
 net/rmnet_data/rmnet_map.h              |  148 ++++
 net/rmnet_data/rmnet_map_command.c      |  180 +++++
 net/rmnet_data/rmnet_map_data.c         |  154 +++++
 23 files changed, 3986 insertions(+), 1 deletion(-)
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
