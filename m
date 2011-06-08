From: Karthikeyan Ramasubramanian <kramasub@codeaurora.org>
Subject: [PATCH 0/3] Add support for MSM_IPC Router
Date: Wed,  8 Jun 2011 11:49:05 -0600
Message-ID: <1307555345-924-1-git-send-email-kramasub@codeaurora.org>
Cc: netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	Karthikeyan Ramasubramanian <kramasub@codeaurora.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:26802 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049Ab1FHRuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 13:50:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of patches add support for Mobile Station Mode
IPC message Router. The MSM_IPC Router provides a connectionless
message oriented routing mechanism between the processes running
in Qualcomm MSM. Patch 1 adds support for routing functionality.
Patch 2 adds user-space interface support to the MSM_IPC Router.
Patch 3 adds support for the MSM_IPC Router to interface with the
MSM Shared Memory Driver.

This patch series applies to current net-next-2.6.

Please review and consider to apply,
Karthik

Karthikeyan Ramasubramanian (3):
  net: msm_ipc: Add Mobile Station Mode IPC Router
  net: msm_ipc: Add user-space support for MSM_IPC Router
  net: msm_ipc: Add SMD Transport to the MSM_IPC Router

 include/linux/msm_ipc.h               |   74 ++
 include/linux/socket.h                |    5 +-
 net/Kconfig                           |    2 +-
 net/Makefile                          |    1 +
 net/msm_ipc/Kconfig                   |   24 +
 net/msm_ipc/Makefile                  |    4 +
 net/msm_ipc/msm_ipc_router.c          | 1760 +++++++++++++++++++++++++++++++++
 net/msm_ipc/msm_ipc_router.h          |  195 ++++
 net/msm_ipc/msm_ipc_router_smd_xprt.c |  226 +++++
 net/msm_ipc/msm_ipc_socket.c          |  520 ++++++++++
 10 files changed, 2809 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/msm_ipc.h
 create mode 100644 net/msm_ipc/Kconfig
 create mode 100644 net/msm_ipc/Makefile
 create mode 100644 net/msm_ipc/msm_ipc_router.c
 create mode 100644 net/msm_ipc/msm_ipc_router.h
 create mode 100644 net/msm_ipc/msm_ipc_router_smd_xprt.c
 create mode 100644 net/msm_ipc/msm_ipc_socket.c

-- 
1.7.3.3

Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
